module DevcmsCore  
  module ActsAsContentNode
    extend ActiveSupport::Concern      
    
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
      :expiration_container => false,
      :nested_resource => false
    }
  
    included do      
      define_callbacks :before_paranoid_delete, :after_paranoid_delete, :before_paranoid_restore, :after_paranoid_restore

      has_one :node, :as => :content, :autosave => true, :validate => true

      default_scope where("#{table_name}.deleted_at IS NULL")

      scope :with_parent, lambda { |node, options| options.merge({:include => :node, :conditions => [ 'nodes.ancestry = ?', node.child_ancestry ] }) }
      scope :accessible,  lambda { { :include => :node, :conditions => Node.accessibility_and_visibility_conditions } }

      validates_presence_of :node

      before_destroy do |content|
        content.node.destroy(:destroy_content_node => false)
      end

      before_update :touch_node
      after_update  :update_url_alias_if_title_changed

      after_save :update_search_index
          
      before_paranoid_delete :delete_all_associated_versions
      
      after_paranoid_delete :copy_deleted_at_from_node
      
      after_paranoid_restore :clear_deleted_at, :set_url_alias

      delegate :update_search_index, :expirable?, :expiration_required?, :expired?, :expiration_container?, :to => :node

      delegate_accessor :commentable,
                        :content_box_title, :content_box_icon, :content_box_colour, :content_box_number_of_items,
                        :categories, :category_attributes, :category_ids,
                        :parent,
                        :publication_start_date, :publication_end_date,
                        :responsible_user, :responsible_user_id, :expires_on,
                        :expiration_notification_method, :expiration_email_recipient, :cascade_expires_on,
                        :title_alternative_list, :title_alternatives, :pin_id,
                        :defer_geocoding, :location,
                        :short_title, :locale, :to => :node
    end
    
    module ClassMethods
      def before_paranoid_delete(*args, &block);  set_callback(:before_paranoid_delete, :before, *args, &block)   end  
      def after_paranoid_delete(*args, &block);   set_callback(:after_paranoid_delete, :after, *args, &block)     end     
      def before_paranoid_restore(*args, &block); set_callback(:before_paranoid_restore, :before, *args, &block)  end
      def after_paranoid_restore(*args, &block);  set_callback(:after_paranoid_restore, :after, *args, &block)    end        

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

    # Generate a path to suffix the URL alias with. Defaults to the
    # properly formatted content title.
    def path_for_url_alias(node)
      content_title
    end
  
    attr_accessor :draft

    def draft?
      draft == '1' || draft == true
    end
    
    def node
      (super || associate_node).tap{|node| node.content = self }
    end
    
    def associate_node
      build_node.tap{|node| node.sub_content_type = (self.respond_to?(:copied_content_class) ? self.copied_content_class : self.class).name}
    end

    def save(*args)
      versioning_options = args.extract_options!
      
      if user = versioning_options.delete(:user)
        if new_record?
          self.node.created_by = user
        else
          self.node.updated_by = user
        end
      end      
    
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
      super
      self.node.title = value
    end

    # Returns the last update date
    def last_updated_at
      self_and_children = self.node.self_and_children
      scope = self_and_children.accessible unless node.private? && node.hidden?
      [scope.maximum('nodes.updated_at'), self_and_children.accessible.maximum('nodes.publication_start_date')].max
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
    
    def to_label
      title
    end
  
    private

    def update_url_alias_if_title_changed
      if self.respond_to?(:title) && self.title_changed?
        # Update self and descendants
        node.update_subtree_url_aliases
        # Save base_url_alias for later use
        base_url_alias = node.reload.url_alias.sub(/-\d+\Z/, '') # chomp off -1, -2, etc.
        # Search siblings for nodes with identiacal aliases
        node.siblings.all(:conditions => ["url_alias like ?", base_url_alias + '-%']).each do |dupe| 
          dupe.update_subtree_url_aliases
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
    
    def set_url_alias
      node.set_url_alias
      node.save!
    end       
  end
  
end