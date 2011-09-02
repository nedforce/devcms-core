class AddTitleToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :title, :string
    
    add_index :nodes, :title
    
    content_types = Node.connection.select_rows('SELECT nodes.content_type FROM nodes GROUP BY nodes.content_type').flatten
    
    puts "Caching content titles for all nodes, this might take a while.."
    
    content_types.each do |content_type|
      content_class = content_type.constantize
      
      if content_class.column_names.include?('title')
        table_name = content_class.table_name
        
        Node.connection.execute("UPDATE nodes SET title = #{table_name}.title FROM #{table_name} WHERE nodes.content_type = '#{content_type}' AND nodes.content_id = #{table_name}.id")
      end
    end
    
    puts "Content title cached for all nodes. Success!"
  end

  def self.down
    remove_column :nodes, :title
  end
end
