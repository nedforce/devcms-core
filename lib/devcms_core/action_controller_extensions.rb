module DevcmsCore
  module ActionControllerExtensions
    extend ActiveSupport::Concern
    
    module ClassMethods
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
    end
  end
end