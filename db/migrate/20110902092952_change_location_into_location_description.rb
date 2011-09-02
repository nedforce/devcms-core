class ChangeLocationIntoLocationDescription < ActiveRecord::Migration
  def self.up
    if Event.columns.map(&:name).include?('location')
      rename_column :events, :location, :location_description
    end
  end

  def self.down
    if Event.columns.map(&:name).include?('location_description')
      rename_column :events, :location_description, :location
    end
  end
end
