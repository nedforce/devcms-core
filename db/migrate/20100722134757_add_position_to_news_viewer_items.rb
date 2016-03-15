class AddPositionToNewsViewerItems < ActiveRecord::Migration
  def up
    add_column :news_viewer_items, :position, :integer
  end

  def down
    remove_column :news_viewer_items, :position
  end
end
