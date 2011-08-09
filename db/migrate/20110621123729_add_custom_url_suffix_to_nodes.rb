class AddCustomUrlSuffixToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :custom_url_suffix, :string
  end

  def self.down
    remove_column :nodes, :custom_url_suffix
  end
end
