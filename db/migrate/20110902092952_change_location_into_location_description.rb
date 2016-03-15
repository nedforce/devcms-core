class ChangeLocationIntoLocationDescription < ActiveRecord::Migration
  def up
    if Event.columns.map(&:name).include?('location')
      rename_column :events, :location, :location_description
    end
  end

  def down
    if Event.columns.map(&:name).include?('location_description')
      rename_column :events, :location_description, :location
    end
  end
end
