class AddSendMethodToContactForm < ActiveRecord::Migration
  def up
    add_column :contact_forms, :send_method, :integer
  end

  def down
    remove_column :contact_forms, :send_method
  end
end
