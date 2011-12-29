class AddAncestryDepthCachingToNodes < ActiveRecord::Migration
  
  def self.up    
    add_column :nodes, :ancestry_depth, :integer, :default => 0
    
    add_index :nodes, :ancestry_depth
    
    Node.reset_column_information
    
    puts "Caching ancestry depth for all nodes, this might take a while..."

    Node.rebuild_depth_cache!
    puts "Ancestry depth cached for all nodes. Success!"
  end

  def self.down
    remove_column :nodes, :ancestry_depth
  end
end
