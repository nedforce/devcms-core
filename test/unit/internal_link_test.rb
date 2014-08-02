require File.expand_path('../../test_helper.rb', __FILE__)

class InternalLinkTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node     = nodes(:root_section_node)
    @internal_link = links(:internal_link)
    @external_link = links(:external_link)
  end

  def test_should_create_internal_link
    assert_difference 'InternalLink.count', 1 do
      create_internal_link
    end
  end

  def test_should_require_linked_node
    assert_no_difference 'InternalLink.count' do
      internal_link = create_internal_link(:linked_node => nil)
      assert internal_link.errors[:linked_node].any?
    end
  end

  def test_should_set_description_and_title_to_nil_if_blank
    l1 = create_internal_link(:title => '', :description => '')
    assert !l1.new_record?
    assert_nil l1.title
    assert_nil l1.description
    l2 = create_internal_link(:title => nil, :description => nil)
    assert !l2.new_record?
    l2.update_attributes(:user => users(:arthur), :title => '', :description => '')
    assert_nil l2.title
    assert_nil l2.description
  end

  def test_should_not_allow_linked_node_to_be_associated_with_a_link_content_node
    [ @internal_link.node, @external_link.node ].each do |linked_node|
      assert_no_difference 'InternalLink.count' do
        internal_link = create_internal_link(:linked_node => linked_node)
        assert internal_link.errors[:base].any?
      end
    end
  end

  def test_content_title_should_return_title_if_title_exists
    assert_equal @internal_link.title, @internal_link.content_title
  end

  def test_content_title_should_return_linked_node_content_title_if_no_title_exists
    @internal_link.update_attribute(:title, nil)
    assert_equal @internal_link.linked_node.content.title, @internal_link.content_title
  end

  def test_should_not_require_unique_title
    assert_difference 'InternalLink.count', 2 do
      2.times do
        internal_link = create_internal_link(:title => 'Non-unique title')
        assert !internal_link.errors[:title].any?
      end
    end
  end

  def test_should_update_internal_link
    assert_no_difference 'InternalLink.count' do
      @internal_link.title = 'New title'
      @internal_link.description = 'New body'
      assert @internal_link.save(:user => users(:arthur))
    end
  end

  def test_should_destroy_internal_link
    assert_difference 'InternalLink.count', -1 do
      @internal_link.destroy
    end
  end

  def test_should_not_allow_linked_node_to_be_contained_in_a_different_site
    assert_no_difference 'InternalLink.count' do
      internal_link = create_internal_link(:parent => nodes(:sub_site_section_node), :linked_node => nodes(:help_page_node))
      assert internal_link.errors[:base].any?
    end
  end

protected

  def create_internal_link(options = {})
    InternalLink.create({ :parent => nodes(:root_section_node), :title => 'This is an internal link', :description => 'Geen fratsen!', :linked_node => @root_node }.merge(options))
  end
end
