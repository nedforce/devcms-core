class AddResposibleEditorToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :responsible_user_id, :integer, :references => :users, :on_delete => :set_null
  end

  def self.down
    remove_column :nodes, :responsible_user_id
  end
end
