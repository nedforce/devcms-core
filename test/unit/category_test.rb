require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = create_category
  end

  def test_should_accept_parent
    parent = create_category(:name => 'Parent')
    @category.parent = parent
    @category.save
    assert @category.save
    assert_equal parent, @category.parent
    assert parent.reload.children.include?(@category)
  end

  def test_should_have_children
    child1 = create_category(:name => 'child1', :parent => @category)
    child2 = create_category(:name => 'child2', :parent => @category)
    @category.reload
    assert @category.children.include?(child1)
    assert @category.children.include?(child2)
  end

  def test_should_validate_presence_of_name
    category = Category.new :name => nil
    assert !category.valid?
  end

  def test_should_have_many_nodes
    node1 = nodes(:help_page_node)
    node2 = nodes(:contact_page_node)
    @category.nodes << node1
    @category.nodes << node2
    assert @category.nodes.include?(node1)
    assert @category.nodes.include?(node2)
  end

  def test_should_get_root_categories
    Category.delete_all

    root_node2 = create_category(:name => 'Cat1')
    root_node2.children << create_category(:name => 'Cat2')
    root_node3 = create_category(:name => 'Cat3')
    root_node3.children << create_category(:name => 'Cat4')
    root_node3.children << create_category(:name => 'Cat5')

    roots = Category.root_categories
    assert_equal 2, roots.size
    assert roots.include?(root_node2)
    assert roots.include?(root_node3)
  end

  def test_root_categories_should_be_unique
    non_unique_category = create_category
    !non_unique_category.valid?
  end

  def test_synonyms_should_be_processed_on_save
    category = create_category(:name => 'Blaat', :synonyms => ' Foo,   Bar, , Baz  ')
    assert_equal 'Foo, Bar, Baz', category.synonyms
  end

protected

  def create_category(options = {})
    Category.create({ :name => 'A category' }.merge(options))
  end
end

