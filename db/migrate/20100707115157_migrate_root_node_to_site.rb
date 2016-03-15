class MigrateRootNodeToSite < ActiveRecord::Migration
  def up
    Node.reset_column_information
    Node.root.content.update_attribute(:type, 'Site') unless Node.unscoped.count.zero?
  end

  def down
    Node.reset_column_information
    Node.root.content.update_attribute(:type, nil) unless Node.unscoped.count.zero?
  end
end
