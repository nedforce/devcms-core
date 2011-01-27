class CreateNewsViewerArchives < ActiveRecord::Migration
  def self.up
    create_table :news_viewer_archives do |t|
      t.integer :news_viewer_id, :references => :news_viewers, :on_delete => :cascade
      t.integer :news_archive_id, :references => :news_archives, :on_delete => :cascade
    end  
    
    add_index :news_viewer_archives, :news_viewer_id
    add_index :news_viewer_archives, :news_archive_id          
  end

  def self.down
    drop_table :news_viewer_archives
  end
end
