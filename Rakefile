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

task :default => :test

gem_helper = Bundler::GemHelper.install_tasks

