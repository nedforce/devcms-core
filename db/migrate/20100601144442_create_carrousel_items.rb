class CreateCarrouselItems < ActiveRecord::Migration
  def self.up
    create_table :carrousel_items do |t|
      t.text :excerpt
      t.references :carrousel, :null => false, :on_delete => :cascade      
      t.string  :item_type, :null => false
      t.integer :item_id, :null => false, :references => nil      
      t.integer :position
    end
    add_index :carrousel_items, :carrousel_id
    add_index :carrousel_items, [:item_type, :item_id]
  end

  def self.down
    drop_table :carrousel_items
  end
end
