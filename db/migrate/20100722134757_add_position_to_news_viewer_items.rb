class AddPositionToNewsViewerItems < ActiveRecord::Migration
  def self.up
    add_column :news_viewer_items, :position, :integer
  end

  def self.down
    remove_column :news_viewer_items, :position
  end
end
