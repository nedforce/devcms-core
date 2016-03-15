class CreateCarrousels < ActiveRecord::Migration
  def up
    create_table :carrousels do |t|
      t.string :title, null: false
      t.timestamps
    end
  end

  def down
    drop_table :carrousels
  end
end
