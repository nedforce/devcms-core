# Core config

config.plugin_paths += Dir["#{File.dirname(__FILE__)}/../vendor/plugins"]
config.i18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '**', '*.{rb,yml}')]
config.autoload_paths += %W(#{RAILS_ROOT}/app/models/node)

config.gem 'acts-as-taggable-on', :version => '2.0.3', :source => 'http://gemcutter.org'
config.gem 'addressable',         :version => '< 2.4', :lib => 'addressable/uri'
config.gem 'ancestry',            :version => '~> 1.3.0'
config.gem 'dsl_accessor',        :version => '0.3.3'
config.gem 'dynamic_attributes',  :version => '~> 1.1.3'
config.gem 'faker',               :version => '~> 0.3.1'
config.gem 'fastercsv'
config.gem 'feed-normalizer',     :version => '~> 1.5.2'
config.gem 'ferret',              :version => '0.11.6'
config.gem 'haml',                :version => '~> 3.0'
config.gem 'libxml-ruby',         :version => '~> 2.7.0', :lib => 'libxml'
config.gem 'mocha',               :version => '~> 0.9.8'
config.gem 'pg',                  :version => '< 0.18'
config.gem 'rmagick',             :version => '>= 2.12.2', :lib => 'RMagick'
config.gem 'settler',             :version => '~> 1.2.3'
config.gem 'shuber-sortable',     :version => '~> 1.0.6', :lib => 'sortable', :source => 'http://gems.github.com'
# use the plugin instead, shuber isn't available as gem anymore
config.gem 'tidy',                :version => '1.1.2'
config.gem 'whenever',            :version => '>= 0.4', :lib => false
config.gem 'spreadsheet',         :version => '~> 0.6.5.2'
config.gem 'roo',                 :version => '~> 1.10.1'
