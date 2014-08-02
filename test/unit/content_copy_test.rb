require File.expand_path('../../test_helper.rb', __FILE__)

class ContentCopyTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node           = nodes(:root_section_node)
    @section_node        = nodes(:economie_section_node)
    @test_image_copy     = content_copies(:test_image_copy)
    @bewoners_forum_copy = content_copies(:bewoners_forum_copy)
    @news_item_node      = nodes(:devcms_news_item_node)
    @weblog_post_node    = nodes(:henk_weblog_post_one_node)
  end

  def test_should_create_content_copy
    assert_difference 'ContentCopy.count', 1 do
      create_content_copy
    end
  end

  def test_should_require_copied_node
    assert_no_difference 'ContentCopy.count' do
      content_copy = create_content_copy(:copied_node => nil)
      assert content_copy.errors[:copied_node].any?
    end
  end

  def test_should_not_allow_copied_node_to_be_associated_with_a_content_copy_content_node
    [ @test_image_copy.node, @bewoners_forum_copy.node ].each do |node|
      assert_no_difference 'ContentCopy.count' do
        content_copy = create_content_copy(:copied_node => node)
        assert content_copy.errors[:base].any?
      end
    end
  end

  def test_should_not_allow_copied_node_to_be_associated_with_a_non_copyable_content_node
    [ @news_item_node, @weblog_post_node ].each do |node|
      assert_no_difference 'ContentCopy.count' do
        content_copy = create_content_copy(:copied_node => node)
        assert content_copy.errors[:base].any?
      end
    end
  end

  def test_should_not_allow_copied_node_to_be_a_site_node
    assert_no_difference 'ContentCopy.count' do
      content_copy = create_content_copy(:copied_node => @root_node)
      assert content_copy.errors[:base].any?
    end
  end

  def test_title_should_return_copied_node_content_title
    assert @test_image_copy.title.include?(@test_image_copy.copied_node.content.title)
  end

  def test_should_destroy_content_copy
    assert_difference 'ContentCopy.count', -1 do
      @test_image_copy.destroy
    end
  end

  def test_content_copy_should_mimic_insertion_behaviour_of_copied_content_node
    assert_nothing_raised do
      @bewoners_forum_copy.node.move_to_child_of(@root_node)
    end

    assert_nothing_raised do
      @bewoners_forum_copy.node.move_to_child_of(@section_node)
    end

    assert_raise ActiveRecord::ActiveRecordError do
      @bewoners_forum_copy.node.move_to_child_of(@news_item_node)
    end

    assert_raise ActiveRecord::ActiveRecordError do
      @bewoners_forum_copy.node.move_to_child_of(@weblog_post_node)
    end
  end

  def test_should_override_icon_class_getters
    assert_match(/forum/, @bewoners_forum_copy.icon_filename)
    assert_match(/forum/, @bewoners_forum_copy.tree_icon_class)
  end

protected

  def create_content_copy(options = {})
    ContentCopy.create({ :parent => @root_node, :copied_node => @section_node }.merge(options))
  end
end
