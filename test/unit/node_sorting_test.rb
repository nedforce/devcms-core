require File.expand_path('../../test_helper.rb', __FILE__)

class NodeSortingTest < ActiveSupport::TestCase

  def setup
    Node.root.reorder_children
    @root_node             = nodes(:root_section_node)
    @about_page_node       = nodes(:about_page_node)
    @economie_section_node = nodes(:economie_section_node)
  end

  def test_should_sort_children
    node = @root_node
    node.sort_children
  end

  def test_should_insert_in_position_on_move_to_left
    n = create_page(:parent => @economie_section_node).node
    pos = @about_page_node.position
    n.move_to_left_of @about_page_node
    assert_equal(@root_node, n.parent)
    assert_equal @about_page_node, n.right_sibling
    assert_equal pos, n.position
    assert_equal @about_page_node.reload.position - 1, n.position 
  end

  def test_should_insert_as_last_on_move_to_parent
    n = create_page(:parent => @economie_section_node).node
    pos = @root_node.children.maximum(:position) + 1
    n.move_to_child_of @root_node
    assert_equal(@root_node, n.parent)
    assert_equal pos, n.position
    assert n.last?
  end

  def test_should_not_update_position_if_not_moved
    n = Node.root.children.first
    pos = n.position
    n.update_attributes :show_in_menu => !n.show_in_menu
    assert_equal pos, n.reload.position, "Node position updated!"
  end

  def test_should_not_remove_from_list_on_paranoid_delete
    n = Node.root.children.first
    max_pos = Node.root.children.last.position
    n.paranoid_delete!
    assert_equal max_pos - 1, Node.root.children.last.position
    assert_nil Node.unscoped.find(n.id).position
  end

  protected
  def create_page(options = {})
    Page.create({ :user => users(:arthur), :parent => nodes(:root_section_node), :title => 'foo', :preamble => 'xuu', :body => 'bar' }.merge(options))
  end

end