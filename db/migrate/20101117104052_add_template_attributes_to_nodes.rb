class AddTemplateAttributesToNodes < ActiveRecord::Migration
  def up
    add_column :nodes, :layout,               :string
    add_column :nodes, :layout_variant,       :string
    add_column :nodes, :layout_configuration, :text
  end

  def down
    remove_column :nodes, :layout
    remove_column :nodes, :layout_variant
    remove_column :nodes, :layout_configuration
  end
end
