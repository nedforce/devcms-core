class AddPasswordResetFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_expiration, :datetime
  end

  def self.down
    remove_column :users, :password_reset_expiration
    remove_column :users, :password_reset_token
  end
end
