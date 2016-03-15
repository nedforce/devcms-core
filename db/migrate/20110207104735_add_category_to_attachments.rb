class AddCategoryToAttachments < ActiveRecord::Migration
  def up
    add_column :attachments, :category, :string, null: false, default: ''
  end

  def down
    remove_column :attachments, :category
  end
end
