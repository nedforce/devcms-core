class RefactorVersioningColumns < ActiveRecord::Migration
  
  class Node < ActiveRecord::Base
  end
  
  class Version < ActiveRecord::Base
  end
  
  def self.up
    raise(Exception, 'This migration cannot be carried out because there are still versions present in the database!') unless Version.count.zero?
    
    add_column :nodes, :publishable, :boolean, :null => false, :default => false
    
    remove_column :nodes, :status
    remove_column :nodes, :edited_by
    remove_column :nodes, :editor_comment
    
    add_index :nodes, :publishable
    
    Node.reset_column_information
    
    Node.update_all 'publishable = true'
    
    add_column :versions, :status, :string, :null => false
    add_column :versions, :editor_id, :integer, :references => :users
    add_column :versions, :editor_comment, :text
    
    add_index :versions, :status
    add_index :versions, :editor_id
  end

  def self.down
    remove_column :nodes, :publishable
    
    add_column :nodes, :status, :string
    add_column :nodes, :edited_by, :integer
    add_column :nodes, :editor_comment, :text
    
    Node.reset_column_information
    
    Node.update_all "status = 'approved'"
    
    remove_column :versions, :status
    remove_column :versions, :editor_id
    remove_column :versions, :editor_comment
  end
end
