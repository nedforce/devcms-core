class ChangeLoidColumnType < ActiveRecord::Migration
  def up
    change_column :db_files, :loid, :oid
  end

  def down
    change_column :db_files, :loid, :int
  end
end
