plugin_root = File.dirname(__FILE__)

# Add additional load paths for your own custom dirs
ActiveSupport::Dependencies.autoload_paths += ["#{plugin_root}/app/sweepers", "#{plugin_root}/app/uploaders"]

Dir["#{plugin_root}/config/initializers/**/*.rb"].sort.each do |initializer|
  require(initializer)
end if FileTest.exist?("#{RAILS_ROOT}/config/initializers/exception_notifier.rb")

if Rails.env.development?
   ActiveSupport::Dependencies.autoload_once_paths.reject!{ |x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/ }
   ActiveSupport::Dependencies.autoload_once_paths << "#{plugin_root}/app/models/dev_cms_core.rb"
end
