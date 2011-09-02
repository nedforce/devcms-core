class AddSubContentTypeToNodes < ActiveRecord::Migration
  
  class Node < ActiveRecord::Base; end
  
  def self.up
    add_column :nodes, :sub_content_type, :string
    
    add_index :nodes, :sub_content_type
    
    puts "Storing sub content types for all nodes, this might take a while.."
    
    Node.reset_column_information
    
    Node.update_all('sub_content_type = content_type')
    
    Node.connection.execute("UPDATE nodes SET sub_content_type = sections.type FROM sections WHERE nodes.content_type = 'Section' AND nodes.content_id = sections.id AND sections.type IS NOT NULL")
    
    Node.connection.execute("UPDATE nodes SET sub_content_type = links.type FROM links WHERE nodes.content_type = 'Link' AND nodes.content_id = links.id AND links.type IS NOT NULL")
    
    Node.connection.execute("UPDATE nodes SET sub_content_type = events.type FROM events WHERE nodes.content_type = 'Event' AND nodes.content_id = events.id AND events.type IS NOT NULL")
    
    puts "Sub content type stored for all nodes. Success!"
    
    change_column_null :nodes, :sub_content_type, false
  end

  def self.down
    remove_column :nodes, :sub_content_type
  end
end
