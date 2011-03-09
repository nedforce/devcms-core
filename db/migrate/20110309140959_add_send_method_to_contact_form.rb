class AddSendMethodToContactForm < ActiveRecord::Migration
  def self.up
    add_column :contact_forms, :send_method, :integer
  end

  def self.down
    remove_column :contact_forms, :send_method
  end
end
