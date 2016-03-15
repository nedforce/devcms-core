class AddBlockedAndFailedLoginsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :blocked,       :boolean, default: false
    add_column :users, :failed_logins, :integer, default: 0
  end

  def down
    remove_column :users, :failed_logins
    remove_column :users, :blocked
  end
end
