class CreateResponses < ActiveRecord::Migration
  def self.up
    create_table :responses do |t|
      t.integer :contact_form_id
      t.string :ip
      t.datetime :time

      t.timestamps
    end
  end

  def self.down
    drop_table :responses
  end
end
