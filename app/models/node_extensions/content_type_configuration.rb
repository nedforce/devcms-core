module NodeExtensions::ContentTypeConfiguration
  extend ActiveSupport::Concern

  module ClassMethods
    def register_content_type(class_name, configuration)
      DevcmsCore::Engine.register_content_type(class_name, configuration)
    end

    def content_types_configuration
      DevcmsCore::Engine.content_types_configuration
    end

    def content_type_configuration(class_name)
      DevcmsCore::Engine.content_type_configuration(class_name)
    end
  end
  
  def content_type_configuration 
    Node.content_type_configuration(self.sub_content_type)
  end

end
