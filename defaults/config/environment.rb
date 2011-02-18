# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_resource ]

  # Gem dependencies
  config.gem 'rsolr'
  config.gem 'wkhtmltopdf-binary',    :version => '~> 0.9.5'
  
  config.action_controller.session = {
    :session_key => '_deventer_session',
    :secret      => '766afa393f5c2d70a243149f13a3b1ad8bab2feef1de0d2427406bd75ac417c2f94b2538c5c0f512af9f0c2f5d416e226b4d6e8cb50b83a5477a850d17aa0afc'
  }

  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
  
  # Load engine environments for gem dependecies etc.
  silence_warnings do
    Dir["#{RAILS_ROOT}/vendor/plugins/devcms-*/config/environment.rb"].each do |env_path|
      eval(IO.read(env_path), binding, env_path)
    end
  end
end