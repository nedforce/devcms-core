module Acts #:nodoc:
  module ContentNode #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end
    
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
      :has_edit_items => false
    }

    # This act provides objects with the behavior to function as content nodes.
    # Refer to Node for implementation details of the content node system.
    #
    # Companion to this mixin is the Acts::ContentNode::TestHelper::ClassMethods
    # test helper mixin to test the behavior of acts_as_content_node.
    module ClassMethods
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
      # Allowed configuration adn defaults, can be overridden from application
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
      
      def acts_as_content_node(configuration = {})
        
        raise "Invalid content configuration, hash expexted" unless configuration.is_a?(Hash)
        configuration.keys.each do |key|
          raise "Invalid content configuration options, unknown key: :#{key}" unless DEFAULT_CONTENT_TYPE_CONFIGURATION.keys.include?(key.to_sym)
        end
        
        # Register content type and configuration
        Node.register_content_type(self, DEFAULT_CONTENT_TYPE_CONFIGURATION.merge(configuration))
        
        # node_id not validated here, because it will be set properly after create.
        has_one :node, :as => :content

        named_scope :with_node,   lambda{|node| { } }
        named_scope :with_parent, lambda{|node, options| options.merge({:include => :node, :conditions => ['nodes.ancestry = ?', node.child_ancestry ] }) }
  
        # If set to true, then the content node will be instructed to keep
        # from calling the destroy_ancestors callback. This is necessary to
        # successfully renumber the tree when destroying a nested subtree.
        #attr_accessor :skip_before_destroy_ancestors

        delegate :update_search_index, :to => :node
        delegate_accessor_to_node :commentable,
                                  :content_box_title, :content_box_icon, :content_box_colour, :content_box_number_of_items,
                                  :categories, :category_attributes, :category_ids, :keep_existing_categories,
                                  :parent,
                                  :publication_start_date, :publication_end_date,
                                  :responsible_user, :responsible_user_id,
                                  :title_alternative_list, :title_alternatives

        validate  :ensure_publication_start_date_is_present_when_publication_end_date_is_present,
                  :ensure_publication_end_date_after_publication_start_date,
                  :ensure_content_box_number_of_items_should_be_greater_than_two

        validates_presence_of :publication_start_date
        validates_length_of :content_box_title, :in => 2..255, :allow_blank => true
        validates_inclusion_of :content_box_colour, :in => DevCMS.content_box_colours, :allow_blank => true
        validates_inclusion_of :content_box_icon, :in => DevCMS.content_box_icons, :allow_blank => true

        validate :valid_responsible_user_role
        validate :validate_parent

        self.extend FindAccessible::ClassMethods

        before_destroy do |content|
          content.node.destroy(:destroy_content_node => false)
        end

        # Sets the publication_start_date to the current time if none is specified
        before_validation_on_create :set_publication_start_date_to_current_time_if_blank

        # Ferret AR hooks
        after_save :update_search_index, :touch_node
          
        # A private copy of the original node setter that is used for overloading node=
        alias_method :original_node=, :node=
        private :original_node=
              
        def has_parent(type, options = {})
          class_name = (options.delete(:class_name) || type.to_s.classify)          
          define_method(type){ (parent || node.try(:parent)).present? ? class_name.constantize.first(:include => :node, :conditions => ['nodes.id = ?', parent || node.try(:parent) ]) : nil }
        end
                  
        def has_children(type, options = {})
          class_name = (options.delete(:class_name) || type.to_s.classify)
          define_method(type){ class_name.constantize.with_parent(node, options)}          
        end        

        self.class_eval do                            
          # Register that this is now a content node.
          def self.is_content_node?
            true
          end

          # Content nodes are indexable by the search engine by default.
          def self.indexable?
            true
          end

          # Generate a path to suffix the URL alias with. Defaults to the
          # properly formatted content title.
          def path_for_url_alias(node)
            content_title
          end

          # Sets the +Node+ that is associated with this content node.
          #
          # This method has been overloaded to make the +Node+ property
          # read-only once it has been set. Once set, this method will
          # essentially disappear by throwing a +NoMethodError+ exception.
          def node=(node)
            if self.original_node.nil?
              original_node = node
            else
              raise NoMethodError
            end
          end
          
          alias_method :original_node, :node
          def node
            if new_record? && self.original_node.blank?
              self.build_node(:content => self)
            else
              self.original_node
            end
          end

          # Returns this content node's title or a substitute.
          # If no title attribute is present 'ModelName #id' is returned,
          # e.g. 'Page 1427'.
          # You might want to override this method in the model.
          def content_title
            self.respond_to?(:title) ? self.title : "#{self.class} #{self.id}"
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
            self.class.to_s.underscore + "_icon"
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
          
          unless respond_to? :accessible_children_for
            def accessible_children_for *args
              []
            end
          end

        private

          # Validation callbacks

          def ensure_publication_start_date_is_present_when_publication_end_date_is_present
            if self.publication_end_date
              self.errors.add_to_base(I18n.t('acts_as_content_node.publication_start_date_should_be_present')) unless self.publication_start_date
            end
          end

          def ensure_publication_end_date_after_publication_start_date
            if self.publication_start_date && self.publication_end_date
              self.errors.add_to_base(I18n.t('acts_as_content_node.publication_end_date_should_be_after_publication_start_date')) if self.publication_start_date >= self.publication_end_date
            end
          end

          def ensure_content_box_number_of_items_should_be_greater_than_two
            if self.content_box_number_of_items
              self.errors.add_to_base(I18n.t('acts_as_content_node.content_box_number_of_items_should_be_greater_than_two')) if self.content_box_number_of_items.to_i <= 2
            end
          end

          # Sets the publication_end_date to current time if none is specified
          def set_publication_start_date_to_current_time_if_blank
            self.publication_start_date = Time.now unless self.publication_start_date
          end

          def touch_node
            node.update_attribute(:updated_at, Time.current)
          end

          def self.valid_parent_class?(klass)
            Node.content_type_configuration(klass.to_s)[:allowed_child_content_types].any? do |content_type|
              class_exists?(content_type) ? (self <= content_type.constantize) : false
            end
          end
          
          def valid_responsible_user_role
            errors.add_to_base(I18n.t('acts_as_content_node.responsible_user_requires_role')) unless node.responsible_user.blank? || node.responsible_user.has_role_on?(['admin', 'editor', 'final_editor'], node)
          end
          

          def validate_parent
            if self.parent
              unless own_content_class.valid_parent_class?(self.parent.content_class)
                errors.add_to_base "'#{self.parent.content_class.human_name}' #{I18n.t('acts_as_content_node.doesnt_accept')} '#{own_content_class.human_name}' #{:type}."
              end
            elsif !Node.count.zero? && Node.root
              errors.add_to_base(I18n.t('acts_as_content_node.could_not_create_content')) if self.new_record?
            end
          end
        end
      end
      
      def delegate_accessor_to_node(*methods)
        methods.each do |m|
          delegate m, "#{m}=", :to => :node
        end
      end
    end
  end
end

