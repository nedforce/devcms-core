module DevcmsCore
  module ContentTypeConfiguration
    extend ActiveSupport::Concern

    included do
      cattr_accessor :modules, :content_types_registered, :_content_types_configuration

      self.modules = []
      self.content_types_registered = false
      self._content_types_configuration = {}
    end

    module ClassMethods

      def register_module(module_name)
        self.modules << module_name
      end

      def is_registered?(module_name)
        self.modules.include?(module_name)
      end

      def registered_modules
        self.modules
      end

      def registered_content_types
        content_types_configuration.keys
      end

      def content_type_configuration(class_name)
        self.content_types_configuration[class_name]
      end

      def content_types_configuration
        register_content_types! unless self.content_types_registered
        self._content_types_configuration
      end

      def register_content_type(type, configuration)
        name = type.is_a?(String) ? type : type.name
        self._content_types_configuration[name] = configuration.merge(Devcms.content_types_configuration[name] || {})
      end

      private

      # Ensures all content types register themselves
      def register_content_types!
        # puts "\"Registering all content types, this might take a while..\""

        config.registered_models.each do |model_file|
          model_file.constantize
        end

        self.content_types_registered = true
      end
    end
  end
end