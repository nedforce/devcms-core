class AddFaqTables < ActiveRecord::Migration
  def change
    create_table :faq_archives, force: true do |t|
      t.string   :title, null: false
      t.text     :description
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :faqs, force: true do |t|
      t.string   :title, null: false
      t.text     :answer
      t.integer  :hits
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
