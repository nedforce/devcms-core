class AddExprirationDateToNodes < ActiveRecord::Migration
  def up
    add_column :nodes, :expires_on, :date
  end

  def down
    remove_column :nodes, :expires_on
  end
end
