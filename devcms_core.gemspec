$:.push File.expand_path('../lib', __FILE__)
require 'devcms_core/version'

# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name        = 'devcms_core'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nedforce Informatica Specialisten B.V.']
  s.email       = ['info@nedforce.nl']
  s.homepage    = 'https://www.nedforce.nl'
  s.summary     = 'CMS engine for Rails 4.2'
  s.description = 'CMS engine for Rails 4.2'
  s.version     = DevcmsCore::VERSION

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_dependency  'rails', '~> 4.2.0'
  s.add_dependency  'acts-as-taggable-on', '~> 3.4.4'
  s.add_dependency  'addressable', '~> 2.1'
  s.add_dependency  'ancestry', '~> 2.1.0'
  s.add_dependency  'dsl_accessor', '0.3.3'
  s.add_dependency  'dynamic_attributes', '~> 1.2.0'
  s.add_dependency  'feed-normalizer', '~> 1.5.2'
  s.add_dependency  'haml', '~> 4.0'
  s.add_dependency  'libxml-ruby', '~> 2.7.0'
  s.add_dependency  'pg', '0.20.0' # Gives deprecation warning from 0.21 on if using Rails 4
  s.add_dependency  'settler', '~> 2.0.1'
  s.add_dependency  'tidy_ffi', '~> 0.1.4'
  s.add_dependency  'whenever', '>= 0.4'
  s.add_dependency  'roo', '~> 1.10.1'
  s.add_dependency  'rubyzip', '= 0.9.9'
  s.add_dependency  'rmagick', '>= 2.13.1'
  s.add_dependency  'kaminari'
  s.add_dependency  'sanitize'
  s.add_dependency  'acts_as_list'
  s.add_dependency  'geokit-rails'
  s.add_dependency  'schema_plus'
  s.add_dependency  'carrierwave'
  s.add_dependency  'rack-rewrite', '~> 1.2.1'
  s.add_dependency  'truncate_html', '~> 0.5.5'
  s.add_dependency  'secure_headers', '~> 2.5'
  s.add_dependency  'data_checker'
  s.add_dependency  'rails-observers', '0.1.2'
  s.add_dependency  'actionpack-page_caching'
  s.add_dependency  'actionpack-action_caching'

  # Airbrake 5.x has a different location for its rake tasks.
  s.add_dependency  'airbrake', '~> 4.3'

  s.add_dependency  'jquery-rails'
  s.add_dependency  'jquery-ui-rails', '~> 5.0.5' # Frontend
  s.add_dependency  'prototype-rails', '~> 4.0.0' # Backend

  ##### Asset helpers (require through bundler in app, not necessary in production always)

  # JavaScript
  s.add_dependency 'coffee-rails'
  s.add_dependency 'uglifier'

  # Styling
  s.add_dependency 'sass-rails', '~> 5.0'

  ##### Development / test dependencies

  s.add_development_dependency 'headhunter'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'faker', '~> 1.0.1'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'rsolr', '~> 0.12.1'
  s.add_development_dependency 'acts_as_ferret', '~> 0.5.4'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'vcr'
end
