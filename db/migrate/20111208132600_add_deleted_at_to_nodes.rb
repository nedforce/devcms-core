class AddDeletedAtToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :deleted_at, :datetime
    add_index  :nodes, :deleted_at

    Node.reset_column_information

    require File.join(DevCMS.core_root, 'lib', 'update_all_and_delete_all_scope_fix.rb')
  end

  def self.down
    remove_column :nodes, :deleted_at
  end
end
