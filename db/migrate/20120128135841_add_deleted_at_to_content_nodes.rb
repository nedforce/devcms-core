class AddDeletedAtToContentNodes < ActiveRecord::Migration
  def self.up
    puts "Copying deleted_at values for all nodes, this might take a while.."
    
    self.content_type_tables.each do |content_type_table|
      add_column content_type_table, :deleted_at, :datetime
      
      add_index content_type_table, :deleted_at
      
      ActiveRecord::Base.connection.execute("UPDATE #{content_type_table} SET deleted_at = nodes.deleted_at FROM nodes WHERE nodes.content_type = '#{content_type_table.classify}' AND nodes.content_id = #{content_type_table}.id AND nodes.deleted_at IS NOT NULL")
    end
    
    puts "Successfully copied deleted_at values for all nodes."
  end

  def self.down
    self.content_type_tables.each do |content_type_table|
      remove_column content_type_table, :deleted_at
    end
  end
  
  def self.content_type_tables
    DevcmsCore::Engine.registered_content_types.map(&:constantize).map(&:table_name).uniq
  end
end
