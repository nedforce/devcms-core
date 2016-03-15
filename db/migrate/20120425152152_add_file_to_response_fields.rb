class AddFileToResponseFields < ActiveRecord::Migration
  def up
    add_column :response_fields, :file, :string
  end

  def down
    remove_column :response_fields, :file
  end
end
