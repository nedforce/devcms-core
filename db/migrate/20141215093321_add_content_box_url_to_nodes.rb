class AddContentBoxUrlToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :content_box_url, :string
  end
end
