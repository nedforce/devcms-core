require File.expand_path('../../test_helper.rb', __FILE__)

class ContentRepresentationTest < ActiveSupport::TestCase

  def setup
    @about_page_node       = nodes(:about_page_node)
    @root_section_node     = nodes(:root_section_node)
    @external_link_node    = nodes(:external_link_node)
    @economie_section_node = nodes(:economie_section_node)
    @first_root_content_representation = Node.root.content_representations.create(target: 'primary_column', content: Node.root.children.where(content_type: 'Section').reorder(position: :desc).first)
    @devcms_news_item_node = nodes(:devcms_news_item_node)
  end

  def test_should_create_content_representation
    assert_difference('ContentRepresentation.count') do
      content_representation = create_content_representation
      assert !content_representation.new_record?, content_representation.errors.full_messages.to_sentence
    end
  end

  def test_should_require_parent
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:parent => nil)
      assert content_representation.new_record?
      assert content_representation.errors[:parent_id].any?
    end
  end

  def test_should_require_content
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:content => nil)
      assert content_representation.new_record?
      assert content_representation.errors[:content_id].any?
    end
  end

  def test_should_require_unique_parent_content_combination
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:parent => @first_root_content_representation.parent, :content => @first_root_content_representation.content)
      assert content_representation.new_record?
      assert content_representation.errors[:content_id].any?
    end
  end

  def test_should_require_valid_target
    [ -1, 'a', 10 ].each do |target|
      assert_no_difference('ContentRepresentation.count') do
        content_representation = create_content_representation(:target => target)
        assert content_representation.new_record?
        assert content_representation.errors[:content].any?
      end
    end
  end

  def test_should_not_allow_content_if_content_is_not_allowed_as_side_box_content
    assert_no_difference('ContentRepresentation.count') do
      content_representation = create_content_representation(:parent => @root_section_node, :content => @devcms_news_item_node)
      assert content_representation.new_record?
      assert content_representation.errors[:content].any?
    end
  end

  def test_should_allow_content_if_content_is_not_in_same_site_as_the_side_box_itself
    assert_difference('ContentRepresentation.count', 1) do
      content_representation = create_content_representation(:parent => nodes(:sub_site_section_node), :content => @economie_section_node)
      assert !content_representation.new_record?
      assert !content_representation.errors[:content].any?
    end
  end

  def test_should_destroy_content_representation
    assert_difference 'ContentRepresentation.count', -1 do
      @first_root_content_representation.destroy
    end
  end

protected

  def create_content_representation(options = {})
    ContentRepresentation.create({ :parent => @root_section_node, :content => @economie_section_node, :target => 'primary_column' }.merge(options))
  end
end
