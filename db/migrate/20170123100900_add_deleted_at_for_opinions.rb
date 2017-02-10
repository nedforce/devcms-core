class AddDeletedAtForOpinions < ActiveRecord::Migration
  def up
    unless column_exists? :opinions, :deleted_at
      add_column :opinions, :deleted_at, :datetime
    end
  end

  def down
    remove_column :opinions, :deleted_at
  end
end
