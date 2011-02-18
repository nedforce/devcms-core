p "Initializing DevCMS Core.."

plugin_root = File.dirname(__FILE__)

# Add additional load paths for your own custom dirs
ActiveSupport::Dependencies.load_paths << "#{plugin_root}/app/sweepers"

Dir["#{plugin_root}/config/initializers/**/*.rb"].sort.each do |initializer|
  require(initializer)
end