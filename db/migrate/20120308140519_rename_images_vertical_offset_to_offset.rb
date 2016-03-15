class RenameImagesVerticalOffsetToOffset < ActiveRecord::Migration
  def up
    rename_column :images, :vertical_offset, :offset
  end

  def down
    rename_column :images, :offset, :vertical_offset
  end
end
