# Provide a simple gemspec so you can easily use your
# project in your rails apps through git.
Gem::Specification.new do |s|
  s.name        = 'devcms_core'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nedforce Informatica Specialisten B.V.']
  s.email       = ['info@nedforce.nl']
  s.homepage    = 'http://www.nedforce.nl'
  s.summary     = 'CMS engine for Rails 3.2'
  s.description = 'CMS engine for Rails 3.2'
  s.version     = '0.0.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_dependency  'rails', '>= 3.2.3', '< 4.0.0'
  s.add_dependency  'acts-as-taggable-on', '~> 2.4.0'
  s.add_dependency  'addressable', '~> 2.1'
  s.add_dependency  'ancestry', '~> 1.3.0'
  s.add_dependency  'dsl_accessor', '0.3.3'
  s.add_dependency  'dynamic_attributes', '~> 1.2.0'
  s.add_dependency  'feed-normalizer', '~> 1.5.2'
  s.add_dependency  'haml', '~> 4.0'
  s.add_dependency  'libxml-ruby', '~> 2.7.0'
  s.add_dependency  'pg'
  s.add_dependency  'settler', '~> 1.2.3'
  s.add_dependency  'tidy_ffi', '~> 0.1.4'
  s.add_dependency  'whenever', '>= 0.4'
  s.add_dependency  'roo', '~> 1.10.1'
  s.add_dependency  'rubyzip', '= 0.9.9'
  s.add_dependency  'rmagick', '>= 2.13.1'
  s.add_dependency  'kaminari'
  s.add_dependency  'sanitize'
  s.add_dependency  'sortifiable'
  s.add_dependency  'geokit-rails'
  s.add_dependency  'aspgems-redhillonrails_core', '~> 2.0.0.beta1'
  s.add_dependency  'aspgems-foreign_key_migrations', '~> 2.0.0.beta1'
  s.add_dependency  'carrierwave'
  s.add_dependency  'bartt-ssl_requirement', '~>1.4.0'
  s.add_dependency  'rack-rewrite', '~> 1.2.1'
  s.add_dependency  'truncate_html', '~> 0.5.5'
  s.add_dependency  'data_checker'
  s.add_dependency  'airbrake'

  s.add_dependency  'jquery-ui-sass-rails', '~> 4.0.3' # Frontend, includes jquery-rails
  s.add_dependency  'prototype-rails', '~> 3.2.1' # Backend

  ##### Asset helpers (require through bundler in app, not necessary in production always)

  # Javascript
  s.add_dependency 'coffee-rails', '~> 3.0'
  s.add_dependency 'coffee-script-source', '~> 1.5.0'
  s.add_dependency 'uglifier'

  # Styling
  s.add_dependency 'sass-rails', '~> 3.0'

  ##### Development / test dependencies

  s.add_development_dependency 'jakewendt-html_test', '~> 0.2.3'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'faker', '~> 1.0.1'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'rsolr', '~> 0.12.1'
  s.add_development_dependency 'acts_as_ferret', '~> 0.5.4'
end
