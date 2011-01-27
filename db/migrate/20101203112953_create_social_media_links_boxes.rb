class CreateSocialMediaLinksBoxes < ActiveRecord::Migration
  def self.up
    create_table :social_media_links_boxes do |t|
      t.string :title,         :null => false

      t.string :twitter_url
      t.string :hyves_url
      t.string :facebook_url
      t.string :linkedin_url
      t.string :youtube_url
      t.string :flickr_url

      t.timestamps
    end
  end

  def self.down
    drop_table :social_media_links_boxes
  end
end
