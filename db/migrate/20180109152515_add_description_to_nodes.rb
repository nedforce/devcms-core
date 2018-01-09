class AddDescriptionToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :section_description, :string
  end
end
