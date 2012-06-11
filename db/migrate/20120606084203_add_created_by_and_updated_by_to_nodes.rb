class AddCreatedByAndUpdatedByToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :created_by_id, :integer, :references => :user
    add_column :nodes, :updated_by_id, :integer, :references => :user
  end

  def self.down
    remove_column :nodes, :updated_by_id
    remove_column :nodes, :created_by_id
  end
end
