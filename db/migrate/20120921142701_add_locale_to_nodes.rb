class AddLocaleToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :locale, :string
  end
end
