class AddFileToAttachments < ActiveRecord::Migration
  def up
    add_column :attachments, :file, :string
  end

  def down
    remove_column :attachments, :file
  end
end
