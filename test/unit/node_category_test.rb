require File.expand_path('../../test_helper.rb', __FILE__)

class NodeCategoryTest < ActiveSupport::TestCase
  def setup
    @node = nodes(:root_section_node)
    @category = categories(:category_blaat)
  end

  def test_should_create_node_category
    assert_difference 'NodeCategory.count' do
      nc = create_node_category
      assert nc.valid?
    end
  end

  def test_should_require_node
    assert_no_difference 'NodeCategory.count' do
      nc = create_node_category(:node => nil)
      assert nc.errors[:node].any?
    end
  end

  def test_should_require_category
    assert_no_difference 'NodeCategory.count' do
      nc = create_node_category(:category => nil)
      assert nc.errors[:category].any?
    end
  end

  def test_should_require_unique_category_node_combination
    assert_difference 'NodeCategory.count' do
      nc = create_node_category
      assert nc.valid?
    end

    assert_no_difference 'NodeCategory.count' do
      nc = create_node_category
      assert nc.errors[:category_id].any?
    end
  end
  
protected
  
  def create_node_category(options = {})
    NodeCategory.create({ :node => @node, :category => @category }.merge(options))
  end
end
