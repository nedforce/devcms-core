class AddGoogleAnalyticsCodeToSites < ActiveRecord::Migration
  def self.up
    add_column :sections, :analytics_code, :string
  end

  def self.down
    remove_column :sections, :analytics_code
  end
end
