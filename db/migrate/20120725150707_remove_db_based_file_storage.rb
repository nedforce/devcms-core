class RemoveDbBasedFileStorage < ActiveRecord::Migration
  def up
    unless Attachment.exists?
      drop_table :db_files, cascade: true
      remove_column :attachments, :db_file_id
    else
      raise 'Unconverted attachments found!'
    end

    unless Image.where(file: nil).exists?
      remove_column :images, :data
    else
      raise 'Unconverted images found!'
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
