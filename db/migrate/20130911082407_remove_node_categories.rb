class RemoveNodeCategories < ActiveRecord::Migration
  def change
    drop_table :node_categories, :categories
  end
end
