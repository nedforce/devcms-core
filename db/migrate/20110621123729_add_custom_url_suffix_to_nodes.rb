class AddCustomUrlSuffixToNodes < ActiveRecord::Migration
  def up
    add_column :nodes, :custom_url_suffix, :string
  end

  def down
    remove_column :nodes, :custom_url_suffix
  end
end
