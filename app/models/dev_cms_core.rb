class DevCMSCore
  @@modules = Array.new()
  
  def self.root
    File.join(File.dirname(__FILE__), "..", "..")
  end
  
  def self.register_module(moduleName)
    @@modules << moduleName
  end
  
  def self.is_registered?(moduleName)
    @@modules.include?(moduleName)
  end
  
  def self.registered_modules
    @@modules
  end
  
end