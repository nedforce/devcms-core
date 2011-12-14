class RemoveColumnsModeFromNodes < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :columns_mode
  end

  def self.down
    add_column :nodes, :columns_mode, :boolean, :default => false
  end
end
