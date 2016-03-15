class AddTimestampsToCarrouselItems < ActiveRecord::Migration
  def up
    add_column :carrousel_items, :created_at, :datetime
    add_column :carrousel_items, :updated_at, :datetime
  end

  def down
    remove_column :carrousel_items, :updated_at
    remove_column :carrousel_items, :created_at
  end
end
