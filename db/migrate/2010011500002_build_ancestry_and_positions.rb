class BuildAncestryAndPositions < ActiveRecord::Migration
  def self.up
    Node.reset_column_information

    if Node.unscoped.count > 0
      say_with_time 'Building ancestry, this will take a while' do
        Node.build_ancestry_from_parent_ids!
      end

      say_with_time 'Checking integrity' do
        Node.check_ancestry_integrity!
      end

      say_with_time 'Setting list positions' do
        Node.build_list_by_order if Node.respond_to?(:build_list_by_order)
      end
    end
  end

  def self.down
  end
end
