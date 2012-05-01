module DevcmsCore
  module ActiveRecordExtensions
    extend ActiveSupport::Concern
    
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
      def acts_as_content_node(configuration = {}, versioning_configuration = {})
        configuration.assert_valid_keys(DevcmsCore::ActsAsContentNode::DEFAULT_CONTENT_TYPE_CONFIGURATION.keys)
  
        # Register content type and configuration
        Node.register_content_type(self, DevcmsCore::ActsAsContentNode::DEFAULT_CONTENT_TYPE_CONFIGURATION.merge(configuration))
  
        versioning_configuration.reverse_merge!(:exclude => [ :id, :created_at, :updated_at ])
  
        acts_as_versioned versioning_configuration
    
        include DevcmsCore::ActsAsContentNode
      end
      
      def acts_as_versioned(options = {})
        options.assert_valid_keys([ :exclude ])
    
        options.reverse_merge!(:exclude => [ :updated_at, :created_at ])
            
        cattr_accessor :acts_as_versioned_excluded_columns
    
        self.acts_as_versioned_excluded_columns = Array(options[:exclude]).map(&:to_s)
    
        include DevcmsCore::ActsAsVersioned
      end      
                  
      # ActsAsArchive can be used to find items of certain archives based on their publication date
      # *Options*
      # * +items_name+ 
      # * +date_field_model_name+
      # * +date_field_database_name+
      # * +sql_options+
      def acts_as_archive(options = {})
        options = options.dup
        options.symbolize_keys!
        options.assert_valid_keys(:items_name, :date_field_model_name, :date_field_database_name, :sql_options)
        
        options.reverse_merge!({
          :date_field_database_name => 'nodes.publication_start_date',
          :date_field_model_name => :publication_start_date,
          :sql_options => { :include => :node }
        })

        class_inheritable_accessor :acts_as_archive_configuration

        self.acts_as_archive_configuration = options

        include DevcmsCore::ActsAsArchive
      end
            
      # Mixes-in the behaviour for a controller surrounding a archive resource specified with ActsAsArchive
      # By default only adds read actions (show, index)
      #
      # *Parameters*
      # * +model_name+ singular model name as string or symbol
      #
      # *Options*
      # * +allow_create+ Add create and new actions
      # * +allow_update+ Add update and edit actions
      def acts_as_archive_controller(model_name, options = {})
        include DevcmsCore::ActsAsArchiveController

        prepend_before_filter :find_parent_node, :only => [ :new, :create ]
        before_filter :find_record,              :only => [ :show, :edit, :update ]
        before_filter :set_commit_type,          :only => [ :create, :update ]
        before_filter :parse_date_parameters,    :only => [ :index ]
        layout false

        self.singular_name      = model_name.to_s
        self.content_class_name = singular_name.camelize
        self.date_attribute     = options[:date_attribute] || :created_at
        self.weeks              = options[:weeks]          || false

        include DevcmsCore::ActsAsArchiveController::CreateMethods unless options[:allow_create] == false
        include DevcmsCore::ActsAsArchiveController::UpdateMethods unless options[:allow_update] == false
      end
      
      def needs_editor_approval
        include DevcmsCore::NeedsEditorApproval
      end
      
      def human_name
        model_name.human
      end
      
    end
    
    def attributes_from_column_definition
      self.class.column_defaults.dup     
    end
  end
end