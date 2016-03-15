class AddDynamicAttributesToEvents < ActiveRecord::Migration
  def up
    add_column :events, :dynamic_attributes, :text
  end

  def down
    remove_column :events, :dynamic_attributes
  end
end
