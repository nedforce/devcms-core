class CreateEventRegistrations < ActiveRecord::Migration
  def self.up
    create_table :event_registrations do |t|
      t.references :event
      t.references :user
      t.integer :people_count
      t.timestamps
    end
  end

  def self.down
    drop_table :event_registrations
  end
end
