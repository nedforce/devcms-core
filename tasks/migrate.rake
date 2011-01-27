namespace :db do
  task :migrate => [:sync_migrations]
  
  desc "Copies all generic migrations from the treehouse core to the application migration directory."
  task :sync_migrations do
    plugin_root = File.expand_path(File.join(File.dirname(__FILE__), ".."))
    Engines.mirror_files_from(File.join(plugin_root, "db", "migrate"), File.join(RAILS_ROOT, "db", "migrate"))
  end
  
  desc "Replaces all existing schema migrations with the migration versions found in the application migration directory. Use it when migrations are changed, but the database schema remains the same."
  task :replace_schema_migrations => :environment do
    schema_migrations_table = ActiveRecord::Migrator.schema_migrations_table_name
    p "Truncating the schema migrations table..."
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{schema_migrations_table}")
    migrator = ActiveRecord::Migrator.new(:up, File.join(Rails.root,'db','migrate'))
    migrator.migrations.map(&:version).each{|version| p "Inserting migration version #{version}..."; ActiveRecord::Base.connection.insert("INSERT INTO #{schema_migrations_table} (version) VALUES ('#{version}')") }    
    p "All done!"
  end  
end