class AddAncestryToNode < ActiveRecord::Migration
  def up
    add_column :nodes, :ancestry, :string
    add_index :nodes, :ancestry
  end

  def down
    remove_column :nodes, :ancestry
  end
end
