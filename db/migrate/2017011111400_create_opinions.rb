class CreateOpinions < ActiveRecord::Migration

  def up
    create_table "opinion_entries", force: true do |t|
      t.integer  "feeling",               null: false
      t.integer  "description",           null: false
      t.string   "text"
      t.integer  "opinion_id",            null: false, references: nil
    end

    create_table "opinions",              force: true do |t|
      t.string   "title"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "entry_1_1"
      t.string   "entry_1_2"
      t.string   "entry_1_3"
      t.string   "entry_1_4"
      t.string   "entry_2_1"
      t.string   "entry_2_2"
      t.string   "entry_2_3"
      t.string   "entry_2_4"
      t.string   "entry_3_1"
      t.string   "entry_3_2"
      t.string   "entry_3_3"
      t.string   "entry_3_4"
    end

    add_index "opinions", ["created_at"], name: "index_opinions_on_created_at"
    add_index "opinions", ["updated_at"], name: "index_opinions_on_updated_at"

    add_index "opinion_entries", ["opinion_id"], name: "opinion_entries_on_opinion_id"

    add_foreign_key "opinion_entries", "opinions", on_delete: :cascade, name: "opinion_entries_opinion_id_fkey"
  end

  def down
    drop_table "opinion_entries"
    drop_table "opinions"
  end

end
    
