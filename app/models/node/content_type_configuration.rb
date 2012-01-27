module Node::ContentTypeConfiguration
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  def content_type_configuration 
    Node.content_type_configuration(self.content_class.name)
  end
  
  module ClassMethods
    def register_content_type(type, configuration)
      @content_types_configuration ||= {}
      name = type.is_a?(String) ? type : type.name    
      @content_types_configuration[name] = configuration.merge(DevCMS.content_types_configuration[name] || {})
    end

    def content_types_configuration
      @content_types_configuration || {}
    end

    def content_type_configuration(class_name)
      @content_types_configuration[class_name]
    end
    
    # Ensures all models register themselves
    def preload_models!
      # We can only preload the models when the DevCMS framework has been fully initialized
      return if !defined?(DEVCMS_INITIALIZED) || defined?(Rake)
      
      puts "\"Preloading all models, this might take a while..\""
      
      (Dir["#{RAILS_ROOT}/app/models/*.rb"] + Dir["#{RAILS_ROOT}/vendor/plugins/devcms-*/app/models/*.rb"]).each do |f|
        model_type = File.basename(f, '.*').camelize
        
        unless model_type == self.name
          begin
            model_type.constantize
          rescue Exception
          end
        end
      end
    end
  end

end
