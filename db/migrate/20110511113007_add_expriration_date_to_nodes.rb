class AddExprirationDateToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :expires_on, :date
  end

  def self.down
    remove_column :nodes, :expires_on
  end
end
