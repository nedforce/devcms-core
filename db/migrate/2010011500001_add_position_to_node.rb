class AddPositionToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :position, :integer
    add_index :nodes, :position
  end

  def self.down
    remove_column :nodes, :position
  end
end
