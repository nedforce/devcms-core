# Add additional load paths for your own custom dirs
ActiveSupport::Dependencies.load_paths << "#{File.dirname(__FILE__)}/app/sweepers"

if Rails.env.development?
  ActiveSupport::Dependencies.load_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
end