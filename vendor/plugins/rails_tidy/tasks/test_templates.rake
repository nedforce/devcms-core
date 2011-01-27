namespace :test do
  desc "validate html in templates"
  task :templates => :environment do
    require File.join(File.dirname(__FILE__),"..", "lib", "rails_tidy")
    RailsTidy.path = ENV["FILE"] if ENV.key?("FILE")
    RailsTidy.run
  end
end
