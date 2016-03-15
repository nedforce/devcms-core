class AddSubscriptionEnabledToEvents < ActiveRecord::Migration
  def up
    add_column :events, :subscription_enabled, :boolean, default: false
  end

  def down
    remove_column :events, :subscription_enabled
  end
end
