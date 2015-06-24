class RemoveRememberTokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
    remove_column :users, :remember_token_ip
  end

  def down
    add_column :users, :remember_token,            :string
    add_column :users, :remember_token_expires_at, :datetime
    add_column :users, :remember_token_ip,         :string
    add_index  :users, :remember_token
  end
end
