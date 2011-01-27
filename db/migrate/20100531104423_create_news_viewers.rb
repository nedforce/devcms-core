class CreateNewsViewers < ActiveRecord::Migration
  def self.up
    create_table :news_viewers do |t|
      t.string :title, :null => false
      t.text :description
      t.timestamps
    end
    
    create_table :news_viewer_items do |t|
      t.integer :news_viewer_id, :references => :news_viewers, :on_delete => :cascade
      t.integer :news_item_id, :references => :news_items, :on_delete => :cascade
    end  
    
    add_index :news_viewer_items, :news_viewer_id
    add_index :news_viewer_items, :news_item_id          
  end

  def self.down
    drop_table :news_viewer_items
    drop_table :news_viewers
  end
end
