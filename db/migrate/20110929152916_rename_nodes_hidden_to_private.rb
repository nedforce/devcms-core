class RenameNodesHiddenToPrivate < ActiveRecord::Migration
  def self.up
    remove_index :nodes, :hidden
    
    rename_column :nodes, :hidden, :private
    
    add_index :nodes, :private
  end

  def self.down
    remove_index :nodes, :private
    
    rename_column :nodes, :private, :hidden
    
    add_index :nodes, :hidden
  end
end
