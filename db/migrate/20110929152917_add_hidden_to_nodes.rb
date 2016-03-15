class AddHiddenToNodes < ActiveRecord::Migration
  class Node < ActiveRecord::Base
  end

  def up
    add_column :nodes, :hidden, :boolean, default: false, null: false
    add_index  :nodes, :hidden

    Node.reset_column_information

    Node.update_all 'hidden = false'
  end

  def down
    remove_column :nodes, :hidden
  end
end
