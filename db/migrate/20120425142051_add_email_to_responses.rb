class AddEmailToResponses < ActiveRecord::Migration
  def self.up
    add_column :responses, :email, :string
  end

  def self.down
    remove_column :responses, :email
  end
end
