class ActiveRecord::Base
  # Mixes in the behavior for objects to function as content nodes. Objects
  # will then gain an 1:1 association called +node+ which is managed by the
  # object itself. The node is set on object creation and immediately
  # becomes read-only afterwards.
  #
  # <b>Child and parent type contraints</b>
  #
  # Content node types can have certain constraints applied to it regarding its accepting
  # types (i.e. content node types of which content nodes are accepted as children),
  # and whether it is insertable in content nodes of any type (default) or not.
  # Override the +allowed_child_content_types+ method to restrain to specific content types
  # that are allowed for child nodes.
  # By default it returns _all_ content types, excluding those registered as 'not insertable'.
  # Use Node's +register_as_not_insertable_content_type+ method to make sure a type
  # will not be insertable into any type that does not override the +allowed_child_content_types+
  # method. (e.g. Add +Node.register_as_not_insertable_content_type(self)+ to the content node's class definition)
  #
  # <b>Specification</b>
  #
  # Parameter
  # +configuration+ Hash with the configuration of this content type. See Configuration for valid options and defaults
  #
  #
  # Preconditions
  #
  # * Requires the presence of +node+. associate_node has been chained to
  #   before_validate to automatically satisfy this precondition.
  # * Requires the +publication_end_date+ to be after the +publication_start_date+.
  #
  # Postconditions
  #
  # * The +node+ will be destroyed after this content node has been.
  #
  # <b>Configuration</b>
  # Allowed configuration and defaults, can be overridden from application
  # * +:enabled+  => true
  # * +:allowed_child_content_types+ => []
  # * +:allowed_roles_for_update+ => %w( admin editor final_editor )
  # * +:allowed_roles_for_create+  => %w( admin editor final_editor )
  # * +:allowed_roles_for_destroy+ => %w( admin editor final_editor )
  # * +:available_content_representations+ => []
  # * +:show_in_menu+ => true
  # * +:copyable+ => true
  # * +:has_own_feed+ => false
  # * +:children_can_be_sorted+ => true
  # * +:has_own_content_box+ => false
  # * +:tree_loader_name+ => 'nodes'
  # * +:controller_name+ => nil
  # * +:show_content_box_header+ => true
  # * +:has_import+ => false
  # * +:has_sync+ => false
  # * +:has_edit_items+ => false

  def self.acts_as_content_node(configuration = {}, versioning_configuration = {})
    configuration.assert_valid_keys(Acts::ContentNode::DEFAULT_CONTENT_TYPE_CONFIGURATION.keys)
  
    # Register content type and configuration
    Node.register_content_type(self, Acts::ContentNode::DEFAULT_CONTENT_TYPE_CONFIGURATION.merge(configuration))
  
    versioning_configuration.reverse_merge!(:exclude => [ :id, :created_at, :updated_at ])
  
    acts_as_versioned versioning_configuration
    
    include Acts::ContentNode unless self.include?(Acts::ContentNode)
  end
end

module Acts
  module ContentNode
    DEFAULT_CONTENT_TYPE_CONFIGURATION = {
      :enabled => true,
      :allowed_child_content_types => [],
      :allowed_roles_for_update  => %w( admin editor final_editor ),
      :allowed_roles_for_create  => %w( admin editor final_editor ),
      :allowed_roles_for_destroy => %w( admin editor final_editor ),
      :available_content_representations => [],
      :show_in_menu => true,
      :has_default_representation => true,
      :copyable => true,
      :has_own_feed => false,
      :children_can_be_sorted => true,
      :has_own_content_box => false,
      :tree_loader_name => 'nodes',
      :controller_name => nil, # Defaults to content_class.table_name
      :show_content_box_header => true,
      :has_import => false,
      :has_sync => false,
      :has_edit_items => false,
      :expirable => false,
      :expiration_required => false,
      :expiration_container => false
    }
    
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        extend ClassMethods
      
        define_callbacks  :before_paranoid_delete, :after_paranoid_delete,
                          :before_paranoid_restore, :after_paranoid_restore
  
        has_one :node, :as => :content, :autosave => true, :validate => true

        if base.content_columns.any? { |column| column.name == 'deleted_at' }
          default_scope :conditions => "#{base.table_name}.deleted_at IS NULL"
        end

        named_scope :with_parent, lambda { |node, options| options.merge({:include => :node, :conditions => [ 'nodes.ancestry = ?', node.child_ancestry ] }) }
        named_scope :accessible,  lambda { { :include => :node, :conditions => Node.accessibility_and_visibility_conditions } }

        validates_presence_of :node

        before_destroy do |content|
          content.node.destroy(:destroy_content_node => false)
        end
  
        before_update :touch_node
        after_update  :update_url_alias_if_title_changed

        after_save :update_search_index
        
        before_paranoid_delete :delete_all_associated_versions
        
        after_paranoid_delete :copy_deleted_at_from_node
        
        after_paranoid_restore :clear_deleted_at
  
        delegate :update_search_index, :expirable?, :expiration_required?, :expired?, :expiration_container?, :to => :node
  
        delegate_accessor :commentable,
                          :content_box_title, :content_box_icon, :content_box_colour, :content_box_number_of_items,
                          :categories, :category_attributes, :category_ids, :keep_existing_categories,
                          :parent,
                          :publication_start_date, :publication_end_date,
                          :responsible_user, :responsible_user_id, :expires_on,
                          :expiration_notification_method, :expiration_email_recipient, :cascade_expires_on,
                          :title_alternative_list, :title_alternatives, :location, :pin_id, :to => :node
      end
    end
      
    module InstanceMethods
    
      # Ugly hack necessary to associate node before attributes are set, as we use delegate to node for some attributes
      def initialize(attributes = nil)
        @attributes = attributes_from_column_definition
        @attributes_cache = {}
        @new_record = true
        ensure_proper_type
        associate_node # Here thar be magic
        self.attributes = attributes unless attributes.nil?
        assign_attributes(self.class.send(:scope, :create)) if self.class.send(:scoped?, :create)
        result = yield self if block_given?
        callback(:after_initialize) if respond_to_without_attributes?(:after_initialize)
        result
      end

      # Generate a path to suffix the URL alias with. Defaults to the
      # properly formatted content title.
      def path_for_url_alias(node)
        content_title
      end
      
      attr_accessor :draft

      def draft?
        draft == '1' || draft == true
      end

      def save(*args)
        versioning_options = args.extract_options!
        
        versioning_options[:should_create_version] = versioning_options[:should_create_version] || self.draft?
        versioning_options[:extra_version_attributes] ||= {}
        versioning_options[:extra_version_attributes][:status] = Version::STATUSES[:drafted] if self.draft?
        
        self.with_versioning(versioning_options) do
          super(*args)
        end
      end
      
      def save!(*args)
        self.save(*args) || raise(ActiveRecord::RecordNotSaved, self.errors.full_messages.join(', '))
      end

      # Make sure the title is stored in the node as well
      def title=(value)
        self.write_attribute(:title, value)
        self.node.write_attribute(:title, value)
      end
    
      # Returns the last update date
      def last_updated_at
        self.node.self_and_descendants.accessible.maximum('nodes.updated_at')
      end
    
      def touch!
        self.update_attribute(:updated_at, Time.now)
      end
    
      def content_title
        self.respond_to?(:title) ? self.title : "#{self.class.name} #{self.id}"
      end

      # Returns this content node's tokens that are available for indexing.
      # By default this returns nil, so you will want to override this in
      # the model.
      def content_tokens
        nil
      end

      # Returns the text to be displayed in tree view.
      # It aliases the _content_title_ method by default.
      # You might want to override this method in the model.
      def tree_text(node)
        content_title
      end

      # Returns the CSS class name to be used for icons in tree view.
      # It uses the 'model_name_icon' by default.
      # You might want to override this method in the model.
      def tree_icon_class
        "#{self.class.to_s.underscore}_icon"
      end

      # Returns the filename to be used for icons in front end website view.
      # It uses the 'model_name_icon.png' by default.
      # You might want to override this method in the model.
      def icon_filename
        "#{self.class.to_s.underscore}.png"
      end

      def commentable?
        !!commentable
      end

      def own_content_class
        (self.class == ContentCopy) ? self.copied_content_class : self.class
      end

      def show_content_box_header
        Node.content_type_configuration(self.class.to_s)[:show_content_box_header]
      end
    
      def show_in_menu
        Node.content_type_configuration(self.class.to_s)[:show_in_menu]
      end
    
      def controller_name
        self.class.controller_name
      end
    
      def sub_themes
        # Bit of a hack. Should only be defined for content classes that allow attachments as a child
        node.children.with_content_type('AttachmentTheme').accessible
      end
      
      # Fix error reporting when there are multiple errors on the associated node's base
      def valid?
        result = super
        
        self.errors.instance_variable_get('@errors').delete('node.base')
        
        if self.node.errors.on_base
          self.node.errors.on_base.each do |error|
            self.errors.add_to_base(error)
          end
        end
        
        result
      end
      
    private
  
      def associate_node
        node = self.build_node :content => self
        node.sub_content_type = self.class.name
      end

      def update_url_alias_if_title_changed
        if self.respond_to?(:title) && self.title_changed?
          # Update self and descendants
          node.set_url_alias(true) 
          node.save
          node.descendants.each do |n| 
            n.set_url_alias(true) 
            n.save
          end
          # Save base_url_alias for later use
          base_url_alias = node.url_alias.sub(/-\d+\Z/, '') # chomp off -1, -2, etc.
          # Search siblings for nodes with identiacal aliases
          node.siblings.all(:conditions => ["url_alias like ?", base_url_alias + '-%']).each do |dupe| 
            dupe.self_and_descendants.each do |n| 
              n.set_url_alias(true)
              n.save
            end
          end
        end
      end

      def touch_node
        self.node.updated_at = Time.now
      end
      
      def copy_deleted_at_from_node
        Node.unscoped do
          node_deleted_at = self.node.deleted_at
          
          self.deleted_at = node_deleted_at
          self.updated_at = node_deleted_at
          
          self.class.update_all({ :deleted_at => node_deleted_at, :updated_at => node_deleted_at }, self.class.primary_key => id)
        end
      end

      def delete_all_associated_versions
        self.versions.delete_all
      end
      
      def clear_deleted_at
        node_updated_at = self.node.updated_at
        
        self.deleted_at = nil
        self.updated_at = node_updated_at
        
        self.class.send(:with_exclusive_scope) do
          self.class.update_all({ :deleted_at => nil, :updated_at => node_updated_at }, self.class.primary_key => id)
        end
      end
    end
  
    module ClassMethods
    
      # Register that this is now a content node.
      def is_content_node?
        true
      end
    
      def requires_editor_approval?
        false
      end

      # Content nodes are indexable by the search engine by default.
      def indexable?
        true
      end
    
      def controller_name
        Node.content_type_configuration(self.to_s)[:controller_name] || self.table_name
      end
    
      def valid_parent_class?(klass)
        Node.content_type_configuration(klass.to_s)[:allowed_child_content_types].any? do |content_type|
          self <= content_type.constantize
        end
      end
    
      def delegate_accessor(*args)
        options = args.extract_options!
      
        args.each do |m|
          delegate m, "#{m}=", options
        end
      end
    
      def has_parent(type, options = {})
        class_name = (options.delete(:class_name) || type.to_s.classify)
        klass = class_name.constantize
      
        define_method(type) {
          (parent || node.try(:parent)).present? ? klass.first(:include => :node, :conditions => ['nodes.id = ?', parent || node.try(:parent) ]) : nil
        }
      
        (class << self; self; end).send(:define_method, :parent_type) { klass }
      end
              
      def has_children(type, options = {})
        class_name = (options.delete(:class_name) || type.to_s.classify)
        define_method(type) { class_name.constantize.with_parent(node, options) }          
      end
    end
  end
end