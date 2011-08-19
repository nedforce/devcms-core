namespace :devcms do
  desc "Installs default config and public assets"
  task :install => :environment do
    ["public", "config", "app", "db"].each do |task|
      Rake::Task["devcms:install:#{task}"].invoke
    end
  end
  
  namespace :install do
    task :public => :environment do
      plugin_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
      Engines.mirror_files_from(File.join(plugin_root, "defaults", "public"), File.join(RAILS_ROOT, "public"))
      indexhtml = File.join(RAILS_ROOT,"public/index.html")
      File.unlink(indexhtml) if File.exists? indexhtml
    end
    
    task :app => :environment do
      plugin_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
      Engines.mirror_files_from(File.join(plugin_root, "defaults", "app"), File.join(RAILS_ROOT, "app"))
    end
    
    task :config => :environment do
      plugin_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
      Engines.mirror_files_from(File.join(plugin_root, "defaults", "config"), File.join(RAILS_ROOT, "config"))
    end
    
    task :db => :environment do
      plugin_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
      Engines.mirror_files_from(File.join(plugin_root, "defaults", "db"), File.join(RAILS_ROOT, "db"))
    end    
  end
end
  
  