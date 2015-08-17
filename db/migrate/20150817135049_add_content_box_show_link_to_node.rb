class AddContentBoxShowLinkToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :content_box_show_link, :boolean, nil: true, default: true
  end
end
