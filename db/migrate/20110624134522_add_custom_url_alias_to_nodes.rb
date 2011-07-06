class AddCustomUrlAliasToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :custom_url_alias, :string
    
    add_index :nodes, :custom_url_alias
  end

  def self.down
    remove_column :nodes, :custom_url_alias
  end
end
