class RemoveColumnsModeFromNodes < ActiveRecord::Migration
  def up
    remove_column :nodes, :columns_mode
  end

  def down
    add_column :nodes, :columns_mode, :boolean, default: false
  end
end
