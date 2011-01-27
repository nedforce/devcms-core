class AddDisplayTimeToCarrousels < ActiveRecord::Migration
  def self.up
    add_column :carrousels, :display_time_in_minutes, :integer
    add_column :carrousels, :current_carrousel_item_id, :integer, :references => :carrousel_items    
    add_column :carrousels, :last_cycled, :datetime
  end

  def self.down
    remove_column :carrousels, :display_time_in_minutes
    remove_column :carrousels, :current_carrousel_item_id
    remove_column :carrousels, :last_cycled
  end
end
