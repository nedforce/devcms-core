class CreateAlphabeticIndices < ActiveRecord::Migration
  def up
    create_table :alphabetic_indices do |t|
      t.string :title, null: false

      t.timestamps
    end
  end

  def down
    drop_table :alphabetic_indices
  end
end
