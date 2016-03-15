class CreateNodeCategories < ActiveRecord::Migration
  def up
    remove_column :nodes, :category_id

    create_table :node_categories do |t|
      t.references :node,     null: false, on_delete: :cascade, on_update: :cascade
      t.references :category, null: false, on_delete: :cascade, on_update: :cascade

      t.timestamps
    end

    add_index :node_categories, [:node_id, :category_id], unique: true
  end

  def down
    drop_table :node_categories

    add_column :nodes, :category_id, :integer

    add_index :nodes, :category_id
  end
end
