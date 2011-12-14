class SetNodesPrivateDefaultToFalse < ActiveRecord::Migration
  def self.up
    change_column_default :nodes, :private, false
  end

  def self.down
    change_column_default :nodes, :private, true
  end
end
