# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

Rails::Initializer.run do |config|
  config.plugin_paths += Dir["#{RAILS_ROOT}/vendor/plugins/*/vendor/plugins"]
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  config.frameworks -= [ :active_resource ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named

  # Gem dependencies
  #config.gem 'pg', :version => '0.8.0'
  if PLATFORM =~ /mswin/
    config.gem 'ferret',              :version => '0.11.5'
    config.gem 'rmagick',             :version => '2.12',     :lib => 'RMagick'
  else
    config.gem 'ferret',              :version => '0.11.6'
    config.gem 'rmagick',             :version => '>=2.12.2', :lib => 'RMagick'
  end

  config.gem 'acts-as-taggable-on',   :version => '2.0.3',                              :source => "http://gemcutter.org"
  config.gem 'addressable',           :version => "~> 2.1",   :lib => 'addressable/uri'
  config.gem 'ancestry',              :version => '~> 1.2.0'
  config.gem 'dsl_accessor',          :version => '0.3.3'
  config.gem 'dynamic_attributes',    :version => '~> 1.1.3'  
  config.gem 'fastercsv'
  config.gem 'feed-normalizer',       :version => '~> 1.5.2'
  config.gem 'haml',                  :version => '~> 3.0'
  config.gem 'libxml-ruby',           :version => "~> 1.1.0", :lib => 'libxml'
  config.gem 'newrelic_rpm'
  config.gem 'pg',                    :version => '~> 0.8'
  config.gem 'rsolr'
  config.gem 'settler',               :version => '~> 1.2.0'
  config.gem 'shuber-sortable',       :version => "~> 1.0.6", :lib => 'sortable',       :source => "http://gems.github.com"
  config.gem 'soap4r',                                        :lib => false
  config.gem 'tidy',                  :version => '1.1.2'
  config.gem 'whenever',              :version => '>= 0.5.0'
  
  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = [ :node_content_sweeper ]

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
end

