require File.dirname(__FILE__) + '/../test_helper'

class TaggableTest < ActiveSupport::TestCase

  def test_node_should_be_taggable_on_title_alternatives
    node = nodes(:root_section_node)
    assert_difference('Tagging.count', 1) do
      node.update_attributes(:title_alternative_list => 'tagje')
    end
    assert_equal 'tagje', node.title_alternatives.to_s
  end
  
  def test_content_should_defer_title_alternative_tagging_to_node
    section = sections(:root_section)
    assert_difference('Tagging.count', 2) do
      section.update_attributes(:title_alternative_list => 'koffie, thee')
    end
    assert_equal 'thee', section.node.title_alternative_list.last.to_s
    assert_equal 'koffie, thee', section.node.title_alternative_list.to_s
  end
  
  def test_should_read_title_alternatives_from_node
    node = nodes(:root_section_node)
    assert_difference('Tagging.count', 1) do
      node.update_attributes(:title_alternative_list => 'tagje2')
    end
    assert_equal 'tagje2', sections(:root_section).title_alternative_list.first
  end
  
  def test_should_update_tags
    node = nodes(:root_section_node)
    node.update_attributes(:title_alternative_list => 'tagje')
    assert_no_difference('Tagging.count') do
      Node.root.reload.update_attributes(:title_alternative_list => 'Nieuw tagje')
    end
    assert_equal 'Nieuw tagje', node.reload.title_alternatives.to_s
  end
end
