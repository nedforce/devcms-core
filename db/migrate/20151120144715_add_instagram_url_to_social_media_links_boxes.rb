class AddInstagramUrlToSocialMediaLinksBoxes < ActiveRecord::Migration
  def change
    add_column :social_media_links_boxes, :instagram_url, :string
  end
end
