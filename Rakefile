begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
require 'schema_plus'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DevCMSCore'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('../test/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

load 'rails/tasks/statistics.rake'

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
  t.warning = false
end

namespace :test do

  Rake::TestTask.new(:models) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/models/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end

  Rake::TestTask.new(:controllers) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/controllers/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end

  Rake::TestTask.new(:mailers) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/mailers/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = false
    t.warning = false
  end

end

task default: :test

