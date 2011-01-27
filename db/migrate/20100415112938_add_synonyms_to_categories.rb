class AddSynonymsToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :synonyms, :text
  end

  def self.down
    remove_column :categories, :synonyms
  end
end
