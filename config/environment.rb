# Core config

config.plugin_paths += Dir["#{File.dirname(__FILE__)}/../vendor/plugins"]
config.i18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '**', '*.{rb,yml}')]

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
config.gem 'pg',                    :version => '~> 0.8.0'
config.gem 'settler',               :version => '~> 1.2.0'
config.gem 'shuber-sortable',       :version => "~> 1.0.6", :lib => 'sortable',       :source => "http://gems.github.com"
config.gem 'tidy',                  :version => '1.1.2'
config.gem 'whenever',              :version => '>= 0.5.0'