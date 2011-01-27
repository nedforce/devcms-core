class AddContentTypeToAlphabeticIndices < ActiveRecord::Migration
  def self.up
    add_column :alphabetic_indices, :content_type, :string, :default => 'Page'
  end

  def self.down
    remove_column :alphabetic_indices, :content_type
  end
end
