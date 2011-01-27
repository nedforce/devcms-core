class CreateAlphabeticIndices < ActiveRecord::Migration
  def self.up
    create_table :alphabetic_indices do |t|
      t.string :title, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :alphabetic_indices
  end
end
