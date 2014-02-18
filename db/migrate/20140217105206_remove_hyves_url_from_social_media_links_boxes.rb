class RemoveHyvesUrlFromSocialMediaLinksBoxes < ActiveRecord::Migration
  def self.up
    remove_column :social_media_links_boxes, :hyves_url
  end

  def self.down
    add_column :social_media_links_boxes, :hyves_url, :string
  end
end
