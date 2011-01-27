class ChangeLoidColumnType < ActiveRecord::Migration
  def self.up
    change_column :db_files, :loid, :oid
  end

  def self.down
    change_column :db_files, :loid, :int
  end
end
