class RenameImagesVerticalOffsetToOffset < ActiveRecord::Migration
  def self.up
    rename_column :images, :vertical_offset, :offset
  end

  def self.down
    rename_column :images, :offset, :vertical_offset
  end
end
