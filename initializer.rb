plugin_root = File.dirname(__FILE__)

Dir["#{plugin_root}/config/initializers/**/*.rb"].sort.each do |initializer|
  require(initializer)
end

I18n.load_path << Dir[File.join(plugin_root, 'config', 'locales', '**', '*.{rb,yml}')]