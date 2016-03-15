class AddMissingIndexToVersionsTable < ActiveRecord::Migration
  def up
    add_index :versions, [:versionable_id, :versionable_type], name: 'index_on_versionable_type'
  end

  def down
  end
end
