class AddFileToImages < ActiveRecord::Migration
  def self.up
    add_column    :images, :file, :string
    change_column_null :images, :data, true
  end

  def self.down
    remove_column :images, :file
    change_column_null :images, :data, false 
  end
end
