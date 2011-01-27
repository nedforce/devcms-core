class AddAncestryToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :ancestry, :string
    add_index :nodes, :ancestry
  end

  def self.down
    remove_column :nodes, :ancestry
  end
end
