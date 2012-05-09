class AddFileToResponseFields < ActiveRecord::Migration
  def self.up
    add_column :response_fields, :file, :string
  end

  def self.down
    remove_column :response_fields, :file
  end
end
