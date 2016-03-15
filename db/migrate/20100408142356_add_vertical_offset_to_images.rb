class AddVerticalOffsetToImages < ActiveRecord::Migration
  def up
    add_column :images, :vertical_offset, :integer
  end

  def down
    remove_column :images, :vertical_offset
  end
end
