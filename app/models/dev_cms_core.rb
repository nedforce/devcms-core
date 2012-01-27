class DevCMSCore
  
  @@modules = []
  
  @@content_types_configuration = {}
  
  def self.root
    File.join(File.dirname(__FILE__), "..", "..")
  end
  
  def self.register_module(module_name)
    @@modules << module_name
  end
  
  def self.is_registered?(module_name)
    @@modules.include?(module_name)
  end
  
  def self.registered_modules
    @@modules
  end
  
  def self.register_content_type(type, configuration)
    name = type.is_a?(String) ? type : type.name    
    @@content_types_configuration[name] = configuration.merge(DevCMS.content_types_configuration[name] || {})
  end

  def self.content_types_configuration
    @@content_types_configuration
  end

  def self.content_type_configuration(class_name)
    @@content_types_configuration[class_name]
  end
  
  # Ensures all models register themselves
  def self.preload_models!
    # We can only preload the models when the DevCMS framework has been fully initialized
    return if !defined?(DEVCMS_CORE_INITIALIZED) || defined?(Rake) || !ActiveRecord::Base.connection.table_exists?('nodes')
    
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