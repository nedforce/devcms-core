class RemoveSideBoxElements < ActiveRecord::Migration
  def self.up
    drop_table :side_box_elements
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
