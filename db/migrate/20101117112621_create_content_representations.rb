class CreateContentRepresentations < ActiveRecord::Migration
  def up
    create_table :content_representations do |t|
      t.integer :parent_id,  null: false, references: :nodes, on_delete: :cascade
      t.integer :content_id, null: false, references: :nodes, on_delete: :cascade
      t.string  :target
      t.integer :position

      t.timestamps
    end

    add_index :content_representations, [:parent_id, :content_id], unique: true
  end

  def down
    drop_table :content_representations
  end
end
