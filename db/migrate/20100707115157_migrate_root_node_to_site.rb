class MigrateRootNodeToSite < ActiveRecord::Migration
  def self.up
    Node.root.content.update_attribute(:type, 'Site') unless Node.count.zero?
  end

  def self.down
    Node.root.content.update_attribute(:type, nil) unless Node.count.zero?
  end
end