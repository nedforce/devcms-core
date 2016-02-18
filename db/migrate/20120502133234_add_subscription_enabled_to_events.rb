class AddSubscriptionEnabledToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :subscription_enabled, :boolean, default: false
  end

  def self.down
    remove_column :events, :subscription_enabled
  end
end
