class BuildAncestryAndPositions < ActiveRecord::Migration


  def self.up
    puts "Building ancestry, this will take a while"
    Node.build_ancestry_from_parent_ids!
    puts "Checking..."
    Node.check_ancestry_integrity!
    puts "Setting list positions..."
    Node.build_list_by_order if Node.respond_to?(:build_list_by_order)
  end

  def self.down
    
  end
end
