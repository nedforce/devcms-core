module Node::ContentTypeConfiguration
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def content_type_configuration 
    Node.content_type_configuration(self.content_class.to_s)
  end
  
  module ClassMethods
      # Register ContentType and fonfiguration, merge with overrides in DevCMS if they exist
    def register_content_type(type, configuration)
      @content_types_configuration ||= {}
      name = type.is_a?(String) ? type : type.name
      @content_types_configuration[name] = configuration.merge(DevCMS.content_types_configuration[name] || {})
    end
  
    def content_types_configuration
      @content_types_configuration
    end
  
    def content_type_configuration(class_name)
      class_exists?(class_name, :constantize => true) ? @content_types_configuration[class_name] : {}
    end
  end
  
end
