class AddMissingIndexToVersionsTable < ActiveRecord::Migration
  def self.up
    add_index "versions", ["versionable_id", "versionable_type"], :name => "index_on_versionable_type"
  end

  def self.down
  end
end
