require File.expand_path('../../test_helper.rb', __FILE__)

class NodeSortingTest < ActiveSupport::TestCase

  def test_should_sort_children
    node = nodes(:root_section_node)
    node.sort_children
  end

end