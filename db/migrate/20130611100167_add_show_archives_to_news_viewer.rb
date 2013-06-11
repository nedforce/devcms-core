class AddShowArchivesToNewsViewer < ActiveRecord::Migration
  def self.up
    add_column :news_viewers, :show_archives, :boolean, default: true
  end
  def self.down
    remove_column :news_viewers, :show_archives
  end
end
