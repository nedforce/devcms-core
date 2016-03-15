class AddEmailToResponses < ActiveRecord::Migration
  def up
    add_column :responses, :email, :string
  end

  def down
    remove_column :responses, :email
  end
end
