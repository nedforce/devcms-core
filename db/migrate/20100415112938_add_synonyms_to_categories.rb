class AddSynonymsToCategories < ActiveRecord::Migration
  def up
    add_column :categories, :synonyms, :text
  end

  def down
    remove_column :categories, :synonyms
  end
end
