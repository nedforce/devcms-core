class AlterContactBoxes < ActiveRecord::Migration
  def self.up
    add_column :contact_boxes, :default_text, :text
    
    [
      :monday_opening_hours, :tuesday_opening_hours, :wednesday_opening_hours, :thursday_opening_hours, 
      :friday_opening_hours, :saturday_opening_hours, :sunday_opening_hours
    ].each do |field|
      remove_column :contact_boxes, field
    end
    
    [
      :monday_text, :tuesday_text, :wednesday_text, :thursday_text, 
      :friday_text, :saturday_text, :sunday_text
    ].each do |field|
      add_column :contact_boxes, field, :text, :null => true
    end
    
  end

  def self.down
    remove_column :contact_boxes, :default_text
    
    [
      :monday_text, :tuesday_text, :wednesday_text, :thursday_text, 
      :friday_text, :saturday_text, :sunday_text
    ].each do |field|
      remove_column :contact_boxes, field
    end
    
    [
      :monday_opening_hours, :tuesday_opening_hours, :wednesday_opening_hours, :thursday_opening_hours, 
      :friday_opening_hours, :saturday_opening_hours, :sunday_opening_hours
    ].each do |field|
      add_column :contact_boxes, field, :string, :null => false
    end
  end
end
