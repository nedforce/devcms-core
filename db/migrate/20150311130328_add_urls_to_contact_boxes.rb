class AddUrlsToContactBoxes < ActiveRecord::Migration
  def change
    add_column :contact_boxes, :more_addresses_url, :string
    add_column :contact_boxes, :more_times_url,     :string
  end
end
