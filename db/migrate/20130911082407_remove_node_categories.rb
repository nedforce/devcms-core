class RemoveNodeCategories < ActiveRecord::Migration
  def change
    drop_table :node_categories
    drop_table :categories, cascade: true
  end
end
