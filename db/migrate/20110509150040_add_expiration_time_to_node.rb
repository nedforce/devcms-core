class AddExpirationTimeToNode < ActiveRecord::Migration
  def self.up
    add_column :nodes, :expiration_time, :integer
  end

  def self.down
    remove_column :nodes, :expiration_time
  end
end
