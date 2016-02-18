class AddCreatedByAndUpdatedByToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :created_by_id, :integer, references: :users
    add_column :nodes, :updated_by_id, :integer, references: :users
  end

  def self.down
    remove_column :nodes, :updated_by_id
    remove_column :nodes, :created_by_id
  end
end
