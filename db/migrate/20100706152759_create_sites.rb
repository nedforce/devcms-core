class CreateSites < ActiveRecord::Migration
  def self.up
    add_column :sections, :type, :string
    add_column :sections, :domain, :string

    add_index :sections, :domain, :unique => true
  end

  def self.down
    remove_column :sections, :type
    remove_column :sections, :domain
  end
end
