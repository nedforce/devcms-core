class SetNodesPrivateDefaultToFalse < ActiveRecord::Migration
  def up
    change_column_default :nodes, :private, false
  end

  def down
    change_column_default :nodes, :private, true
  end
end
