class RemoveTemplates < ActiveRecord::Migration
  def up
    remove_column :nodes, :template_id
    remove_column :nodes, :hide_right_column
    drop_table :templates
  end

  def down
    create_table :templates do |t|
      t.string   :title,       :null => false
      t.string   :description
      t.string   :filename,    :null => false
      t.timestamps
    end

    add_column :nodes, :hide_right_column, :boolean, :default => false    
    add_column :nodes, :template_id, :integer
  end
end
