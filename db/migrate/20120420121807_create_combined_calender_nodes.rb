class CreateCombinedCalenderNodes < ActiveRecord::Migration
  def self.up
    create_table :combined_calendar_nodes do |t|
      t.references :combined_calendar
      t.references :node
    end
    
    add_index :combined_calendar_nodes, :combined_calendar_id
    add_index :combined_calendar_nodes, :node_id    
  end

  def self.down
    drop_table :combined_calendar_nodes
  end
end
