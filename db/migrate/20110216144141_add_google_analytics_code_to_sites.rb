class AddGoogleAnalyticsCodeToSites < ActiveRecord::Migration
  def up
    add_column :sections, :analytics_code, :string
  end

  def down
    remove_column :sections, :analytics_code
  end
end
