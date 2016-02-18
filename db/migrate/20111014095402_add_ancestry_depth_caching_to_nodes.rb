class AddAncestryDepthCachingToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :ancestry_depth, :integer, default: 0
    add_index  :nodes, :ancestry_depth

    # BUG? - this populates the layout_configuration column of all Node objects
    # with an empty hash...
    #Node.reset_column_information

    say_with_time 'Caching ancestry depth for all nodes, this might take a while...' do
      Node.rebuild_depth_cache!
    end
  end

  def self.down
    remove_column :nodes, :ancestry_depth
  end
end
