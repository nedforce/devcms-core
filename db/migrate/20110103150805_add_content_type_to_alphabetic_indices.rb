class AddContentTypeToAlphabeticIndices < ActiveRecord::Migration
  def up
    add_column :alphabetic_indices, :content_type, :string, default: 'Page'
  end

  def down
    remove_column :alphabetic_indices, :content_type
  end
end
