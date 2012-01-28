class AddDeletedAtToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :deleted_at, :datetime
    add_index  :nodes, :deleted_at

    Node.reset_column_information
  end

  def self.down
    remove_column :nodes, :deleted_at
  end
end
