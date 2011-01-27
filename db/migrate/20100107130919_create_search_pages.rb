class CreateSearchPages < ActiveRecord::Migration
  def self.up
    create_table :search_pages do |t|
      t.string :title, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :search_pages
  end
end
