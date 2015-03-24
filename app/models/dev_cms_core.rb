class DevCMSCore
  MODEL_FILES = Dir["#{RAILS_ROOT}/app/models/*.rb"] + Dir["#{RAILS_ROOT}/vendor/plugins/devcms-*/app/models/*.rb"]

  @@modules = []

  @@content_types_registered = false

  @@content_types_configuration = {}

  def self.root
    File.join(File.dirname(__FILE__), '..', '..')
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

  def self.registered_content_types
    content_types_configuration.keys
  end

  def self.content_types_configuration
    register_content_types! unless @@content_types_registered

    @@content_types_configuration
  end

  def self.content_type_configuration(class_name)
    content_types_configuration[class_name]
  end

  def self.register_content_type(type, configuration)
    name = type.is_a?(String) ? type : type.name
    @@content_types_configuration[name] = configuration.merge(DevCMS.content_types_configuration[name] || {})
  end

  private

  # Ensures all content types register themselves
  def self.register_content_types!
    # puts "\"Registering all content types, this might take a while..\""

    MODEL_FILES.each do |model_file|
      next if model_file == __FILE__

      begin
        File.basename(model_file, '.*').camelize.constantize
      rescue
      end
    end

    @@content_types_registered = true
  end
end
