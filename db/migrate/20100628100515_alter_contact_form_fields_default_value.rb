class AlterContactFormFieldsDefaultValue < ActiveRecord::Migration
  def up
    change_column :contact_form_fields, :default_value, :text
  end

  def down
    change_column :contact_form_fields, :default_value, :string
  end
end
