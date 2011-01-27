class CreateCarrousels < ActiveRecord::Migration
  def self.up
    create_table :carrousels do |t|
      t.string :title, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :carrousels
  end
end
