class CreateResponseFields < ActiveRecord::Migration
  def self.up
    create_table :response_fields do |t|
      t.integer :response_id
      t.integer :contact_form_field_id
      t.text :value

      t.timestamps
    end
  end

  def self.down
    drop_table :response_fields
  end
end
