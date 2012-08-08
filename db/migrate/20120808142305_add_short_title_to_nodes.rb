class AddShortTitleToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :short_title, :string
  end
end
