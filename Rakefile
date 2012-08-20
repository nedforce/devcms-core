#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DevCMSCore'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

require 'rake/testtask'

desc "Run continues integration build"
task :cruise do
  ['cruise:setup', 'app:db:drop', 'app:db:create', 'app:db:schema:load', 'test', 'test:integrations', 'cruise:cleanup'].each do |t|
    Rake::Task[t].invoke
  end
end

namespace :cruise do
  task :setup do
    ENV['RAILS_ENV']=ENV['FORCE_RAILS_ENV'] || 'test'
    File.open("#{Rails.root}/config/database.yml",'w') do |f| 
      f.write(
        %Q{
        test:
          adapter: postgresql
          host: #{ENV['DB_HOST'] || 'localhost'}
          database: #{ENV['DB_NAME'] || ''}
          password: #{ENV['DB_PASS'] || ''}
          username: #{ENV['DB_USER'] || ''}
        })
    end
  end

  task :cleanup do
    `mv #{Rails.root}/coverage #{ENV['CC_BUILD_ARTIFACTS']}` if ENV['CC_BUILD_ARTIFACTS'].present?
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/{unit,functional}/*_test.rb'
  t.verbose = false
end

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = false
  end
  
  Rake::TestTask.new(:integrations) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/integration/*_test.rb'
    t.verbose = false
  end  
  
  Rake::TestTask.new(:functionals) do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.pattern = 'test/functional/**/*_test.rb'
    t.verbose = false
  end
  
  namespace :public do
    Rake::TestTask.new(:functionals) do |t|
      t.libs << 'lib'
      t.libs << 'test'
      t.pattern = 'test/functional/*_test.rb'
      t.verbose = false
    end    
  end  
  
  namespace :admin do
    Rake::TestTask.new(:functionals) do |t|
      t.libs << 'lib'
      t.libs << 'test'
      t.pattern = 'test/functional/admin/*_test.rb'
      t.verbose = false
    end    
  end
end

STATS_DIRECTORIES = [
  %w(Controllers        app/controllers),
  %w(Helpers            app/helpers), 
  %w(Models             app/models),
  %w(Mailers            app/mailers),
  %w(Sweepers           app/sweepers),
  %w(Uploaders          app/uploaders),
  %w(validators         app/validators),
  %w(Libraries          lib/),
  %w(APIs               app/apis),
  %w(Integration\ tests test/integration),
  %w(Functional\ tests  test/functional),
  %w(Unit\ tests        test/unit)

].collect { |name, dir| [ name, "#{Rails.root}/../../#{dir}" ] }.select { |name, dir| File.directory?(dir) }

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require 'rails/code_statistics'
  CodeStatistics.new(*STATS_DIRECTORIES).to_s
end

task :default => :test

gem_helper = Bundler::GemHelper.install_tasks

