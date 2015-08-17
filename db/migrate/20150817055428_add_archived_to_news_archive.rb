class AddArchivedToNewsArchive < ActiveRecord::Migration
  def change
    add_column :news_archives, :archived, :boolean, default: false, nil: false
  end
end
