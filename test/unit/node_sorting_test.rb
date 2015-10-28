require File.expand_path('../../test_helper.rb', __FILE__)

class NodeSortingTest < ActiveSupport::TestCase
  setup do
    Node.root.reorder_children
    @root_node             = nodes(:root_section_node)
    @about_page_node       = nodes(:about_page_node)
    @economie_section_node = nodes(:economie_section_node)
  end

  test 'root children should be sorted after setup' do
    assert Node.root.children.broken_list_ancestries.empty?
    assert_equal Node.root.children.map(&:position), (1..Node.root.children.count).to_a
  end

  test 'should sort children' do
    node = @root_node
    node.sort_children
  end

  test 'should insert in position on move to left' do
    n = create_page(parent: @economie_section_node).node
    pos = @about_page_node.position
    n.move_to_left_of @about_page_node
    assert_equal(@root_node, n.parent)
    assert_equal @about_page_node, n.right_sibling
    assert_equal pos, n.position
    assert_equal @about_page_node.reload.position - 1, n.position 
  end

  test 'should insert as last on move to parent' do
    n = create_page(parent: @economie_section_node).node
    pos = @root_node.children.maximum(:position) + 1
    n.move_to_child_of @root_node
    assert_equal(@root_node, n.parent)
    assert_equal pos, n.position
    assert n.last?
  end

  test 'should not update position if not moved' do
    n = Node.root.children.first
    pos = n.position
    n.update_attributes show_in_menu: !n.show_in_menu
    assert_equal pos, n.reload.position, 'Node position updated!'
  end

  test 'should not remove from list on paranoid delete' do
    n = Node.root.children.first
    max_pos = Node.root.children.last.position
    n.paranoid_delete!
    assert_equal max_pos - 1, Node.root.children.last.position
    assert_nil Node.unscoped.find(n.id).position
  end

  test 'should return path in correct order' do
    assert_equal [Node.root, nodes(:economie_section_node)], nodes(:economie_poll_node).path.sections
  end

  protected

  def create_page(options = {})
    Page.create({
      user:     users(:arthur),
      parent:   nodes(:root_section_node),
      title:    'foo',
      preamble: 'xuu',
      body:     'bar'
    }.merge(options))
  end
end
