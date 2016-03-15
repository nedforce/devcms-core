class RemoveSideBoxElements < ActiveRecord::Migration
  def up
    drop_table :side_box_elements
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
