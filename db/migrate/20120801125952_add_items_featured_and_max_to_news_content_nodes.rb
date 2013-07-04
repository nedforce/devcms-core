class AddItemsFeaturedAndMaxToNewsContentNodes < ActiveRecord::Migration
  def change
    add_column :news_archives, :items_featured, :integer
    add_column :news_archives, :items_max,      :integer
    add_column :news_viewers,  :items_featured, :integer
    add_column :news_viewers,  :items_max,      :integer
  end
end
