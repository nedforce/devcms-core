class AlterContactFormFieldsDefaultValue < ActiveRecord::Migration
  def self.up
    change_column :contact_form_fields, :default_value, :text
  end

  def self.down
    change_column :contact_form_fields, :default_value, :string    
  end
end
