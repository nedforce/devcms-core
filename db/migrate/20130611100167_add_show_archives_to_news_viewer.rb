class AddShowArchivesToNewsViewer < ActiveRecord::Migration
  def change
    add_column :news_viewers, :show_archives, :boolean, default: true
  end
end
