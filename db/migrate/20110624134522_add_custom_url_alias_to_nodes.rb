class AddCustomUrlAliasToNodes < ActiveRecord::Migration
  def up
    add_column :nodes, :custom_url_alias, :string
    add_index  :nodes, :custom_url_alias
  end

  def down
    remove_column :nodes, :custom_url_alias
  end
end
