class CreateSearchPages < ActiveRecord::Migration
  def up
    create_table :search_pages do |t|
      t.string :title, null: false

      t.timestamps
    end
  end

  def down
    drop_table :search_pages
  end
end
