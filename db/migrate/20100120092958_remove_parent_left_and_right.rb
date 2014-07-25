class RemoveParentLeftAndRight < ActiveRecord::Migration
  def self.up
    raise "Ensure you migrated the tree structure properly!" unless (Node.count.zero? || Node.root.descendants.count == Node.count - 1)

    remove_column :nodes, :lft
    remove_column :nodes, :rgt
    remove_column :nodes, :parent_id
  end

  def self.down
    puts "WARNING: Requires awesome nested set!"
    add_column :nodes, :lft, :integer
    add_column :nodes, :rgt, :integer
    add_column :nodes, :parent_id, :integer

    Node.reset_column_information

    Node.each { |node| node.update_attribute :parent_id, node.parent.nil? ? 0 : node.parent.id }
  end
end
