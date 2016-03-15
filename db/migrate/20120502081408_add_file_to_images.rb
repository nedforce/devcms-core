class AddFileToImages < ActiveRecord::Migration
  def up
    add_column :images, :file, :string
    change_column_null :images, :data, true
  end

  def down
    remove_column :images, :file
    change_column_null :images, :data, false
  end
end
