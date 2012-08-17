class AddRememberTokenIpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :remember_token_ip, :string
  end
end
