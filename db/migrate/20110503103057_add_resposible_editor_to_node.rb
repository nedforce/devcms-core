class AddResposibleEditorToNode < ActiveRecord::Migration
  def up
    add_column :nodes, :responsible_user_id, :integer, references: :users, on_delete: :set_null
  end

  def down
    remove_column :nodes, :responsible_user_id
  end
end
