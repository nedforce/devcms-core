# This migration comes from data_checker_engine (originally 20130329132131)
class CreateDataWarnings < ActiveRecord::Migration
  def change
    create_table :data_warnings do |t|
      t.integer :subject_id, references: nil
      t.string  :subject_type
      t.string  :error_code
      t.text    :message
      t.string  :status
      t.timestamps
    end
    
    add_index :data_warnings, [:subject_id, :subject_type]
    add_index :data_warnings, :error_code
    add_index :data_warnings, :status    
  end
end
