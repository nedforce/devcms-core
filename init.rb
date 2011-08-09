p "Initializing DevCMS Core.."

plugin_root = File.dirname(__FILE__)

# Add additional load paths for your own custom dirs
ActiveSupport::Dependencies.load_paths << "#{plugin_root}/app/sweepers"

require 'pp'
pp 'xbx'
pp File.basname($0)
pp ARGV

Dir["#{plugin_root}/config/initializers/**/*.rb"].sort.each do |initializer|
  require(initializer)
end  unless ( File.basename($0) == "rake" && (ARGV.include?("devcms:install") || ARGV.include?("devcms:public") || ARGV.include?("devcms:config") || ARGV.include?("devcms:app") || ARGV.include?("devcms:db")) )

# if Rails.env.development?
#   ActiveSupport::Dependencies.load_once_paths.reject!{|x| x =~ /^#{Regexp.escape(File.dirname(__FILE__))}/}
# end