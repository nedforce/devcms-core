require File.dirname(__FILE__) + '/../test_helper'

class ContentRepresentationTest < ActiveSupport::TestCase

  def setup
    @about_page_node = nodes(:about_page_node)
    @root_section_node = nodes(:root_section_node)
    @external_link_node = nodes(:external_link_node)
    @economie_section_node = nodes(:economie_section_node)
    @first_root_content_representation = Node.root.content_representations.create(:target => 'primary_column', :content => Node.root.children.last(:conditions => {:content_type => "Section"}))
    @devcms_news_item_node = nodes(:devcms_news_item_node)
  end

  def test_should_create_content_representation
    assert_difference('ContentRepresentation.count') do
      content_representation = create_content_representation
      assert !content_representation.new_record?, content_representation.errors.full_messages
    end
  end

  def test_should_require_parent
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:parent => nil)
      assert content_representation.new_record?
      assert content_representation.errors.on(:parent_id)
    end
  end

  def test_should_require_content
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:content => nil)
      assert content_representation.new_record?
      assert content_representation.errors.on(:content_id)
    end
  end

  def test_should_require_unique_parent_content_combination
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:parent => @first_root_content_representation.parent, :content => @first_root_content_representation.content)
      assert content_representation.new_record?
      assert content_representation.errors.on(:content_id)
    end
  end

  def test_should_require_valid_target
    [ -1, 'a', 10 ].each do |target|
      assert_no_difference('ContentRepresentation.count') do
        content_representation = create_content_representation(:target => target)
        assert content_representation.new_record?
        assert content_representation.errors.on(:content)
      end
    end
  end

  def test_should_set_default_positions_when_none_are_specified
    content_representation = create_content_representation
    assert_equal 2, content_representation.position
  end

  def test_should_not_allow_content_if_content_is_not_allowed_as_side_box_content
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:parent => @root_section_node, :content => @devcms_news_item_node)
      assert content_representation.new_record?
      assert content_representation.errors.on(:content)
    end
  end

  def test_should_allow_content_if_content_is_not_in_same_site_as_the_side_box_itself
    assert_difference('ContentRepresentation.count', 1) do
      content_representation = create_content_representation(:parent => nodes(:sub_site_section_node), :content => @economie_section_node)
      assert !content_representation.new_record?
      assert !content_representation.errors.on(:content)
    end
  end

  def test_should_destroy_content_representation
    assert_difference "ContentRepresentation.count", -1 do
      @first_root_content_representation.destroy
    end
  end

protected

  def create_content_representation(options = {})
    ContentRepresentation.create({ :parent => @root_section_node, :content => @economie_section_node, :target => 'primary_column' }.merge(options))
  end
end

