class AddPositionToNode < ActiveRecord::Migration
  def up
    add_column :nodes, :position, :integer
    add_index :nodes, :position
  end

  def down
    remove_column :nodes, :position
  end
end
