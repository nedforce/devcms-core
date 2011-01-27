class AddDynamicAttributesToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :dynamic_attributes, :text
  end

  def self.down
    remove_column :events, :dynamic_attributes
  end
end
