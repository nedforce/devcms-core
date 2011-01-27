class CreateNodeCategories < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :category_id

    create_table :node_categories do |t|
      t.references :node, :null => false
      t.references :category, :null => false

      t.timestamps
    end

    add_index :node_categories, [ :node_id, :category_id ], :unique => true
  end

  def self.down
    drop_table :node_categories

    add_column :nodes, :category_id, :integer

    add_index :nodes, :category_id
  end
end
