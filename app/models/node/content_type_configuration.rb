module Node::ContentTypeConfiguration
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def content_type_configuration 
    Node.content_type_configuration(self.content_class.name)
  end
  
  module ClassMethods
    def register_content_type(type, configuration)
      DevCMSCore.register_content_type(type, configuration)
    end

    def content_types_configuration
      DevCMSCore.content_types_configuration
    end

    def content_type_configuration(class_name)
      DevCMSCore.content_type_configuration(class_name)
    end
  end

end
