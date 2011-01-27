class AddVerticalOffsetToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :vertical_offset, :integer
  end

  def self.down
    remove_column :images, :vertical_offset
  end
end
