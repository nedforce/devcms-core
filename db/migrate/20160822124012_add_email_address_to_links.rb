class AddEmailAddressToLinks < ActiveRecord::Migration
  def change
    add_column :links, :email_address, :string
  end
end
