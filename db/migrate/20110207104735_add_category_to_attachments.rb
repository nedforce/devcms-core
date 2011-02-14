class AddCategoryToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :category, :string, :null => false, :default => ""
  end

  def self.down
    remove_column :attachments, :category
  end
end