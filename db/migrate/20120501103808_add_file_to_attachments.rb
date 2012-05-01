class AddFileToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :file, :string
  end

  def self.down
    remove_column :attachments, :file
  end
end
