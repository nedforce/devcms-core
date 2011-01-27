require File.dirname(__FILE__) + '/../test_helper'

class NodeSortingTest < ActiveSupport::TestCase

  def test_should_sort_children
    node = nodes(:root_section_node)
    node.sort_children
  end

end