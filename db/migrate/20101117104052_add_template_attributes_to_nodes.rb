class AddTemplateAttributesToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :layout, :string
    add_column :nodes, :layout_variant, :string
    add_column :nodes, :layout_configuration, :text
  end

  def self.down
    remove_column :nodes, :layout
    remove_column :nodes, :layout_variant
    remove_column :nodes, :layout_configuration
  end
end
