class AddDeletedAtToNodes < ActiveRecord::Migration
  def up
    add_column :nodes, :deleted_at, :datetime
    add_index  :nodes, :deleted_at

    Node.reset_column_information
  end

  def down
    remove_column :nodes, :deleted_at
  end
end
