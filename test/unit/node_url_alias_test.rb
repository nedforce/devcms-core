require File.dirname(__FILE__) + '/../test_helper'

class NodeURLAliasTestTransactional < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  
  def setup
    @arthur = users(:arthur)
    @root_node = nodes(:root_section_node)
    @about_page_node = nodes(:about_page_node)
    @economie_section_node = nodes(:economie_section_node)
  end
  
  def test_should_create_url_alias
    cn = create_page
    assert_equal 'foo', cn.node.url_alias
  end
  
  def test_should_create_custom_url_alias
    cn = create_page
    cn.node.update_attributes(:custom_url_suffix => 'test')
    assert_equal 'test', cn.node.custom_url_alias
  end
  
  def test_should_create_url_alias_for_frontpage_child
    ni = NewsItem.create({:parent => nodes(:devcms_news_node), :title => 'foo', :preamble => 'xuu', :body => 'bar', :publication_start_date => '2008-05-20 12:00' })
    assert_equal '2008/5/20/foo', ni.node.url_alias
  end

  def test_should_remove_trailing_slashes_from_url_aliases
    p = Page.create({:parent => nodes(:root_section_node), :title => 'foo/', :preamble => 'xuu', :body => 'bar', :expires_on => 1.day.from_now.to_date, :publication_start_date => '2008-05-20 12:00' })
    assert_equal 'foo', p.node.url_alias
  end
  
  def test_should_always_generate_unique_alias
    cn = create_page
    assert_equal 'foo', cn.node.url_alias
    cn2 = create_page
    assert_equal 'foo-1', cn2.node.url_alias
  end
  
  def test_should_change_url_alias_when_title_changes
    cn = create_page
    assert_equal 'foo', cn.node.url_alias
    cn.update_attributes(:title => 'foobar')
    assert_equal 'foobar', cn.node.url_alias
  end
  
  def test_should_change_url_alias_when_title_changes_for_non_unique_title
    cn = create_page
    assert_equal 'foo', cn.node.url_alias
    cn2 = create_page :title => 'bar'
    assert_equal 'bar', cn2.node.url_alias
    cn2.update_attributes(:title => 'foo')
    assert_equal 'foo-1', cn2.node.url_alias
  end
  
  def test_should_always_generate_unique_custom_url_alias
    cn = create_page
    cn.node.update_attributes(:custom_url_suffix => 'test')
    assert_equal 'test', cn.node.custom_url_alias
    cn2 = create_page
    cn2.node.update_attributes(:custom_url_suffix => 'test')
    assert_equal 'test-1', cn2.node.custom_url_alias
  end
  
  def test_should_protect_url_alias
    cn = create_page
    assert_equal 'foo', cn.node.url_alias
    cn.node.update_attributes(:url_alias => 'bar')
    assert_equal 'foo', cn.node.url_alias
  end
  
  def test_should_protect_custom_url_alias
    cn = create_page
    cn.node.update_attributes(:custom_url_suffix => 'foo')
    assert_equal 'foo', cn.node.custom_url_alias
    cn.node.update_attributes(:custom_url_alias => 'bar')
    assert_equal 'foo', cn.node.custom_url_alias
  end
  
  def test_should_append_parent_url_alias_if_node_has_parent
    wa = WeblogArchive.create(:parent => @root_node, :title => 'weblogs', :description => 'weblogs')
    parent_node_alias = wa.node.url_alias
    w = wa.weblogs.create(:parent => wa.node, :user => @arthur, :title => 'foobar', :description => 'foobar')
    assert_equal "#{parent_node_alias}/foobar", w.node.url_alias
  end
  
  def test_should_set_custom_url_alias_to_custom_url_suffix_if_node_has_no_parent
    page = create_page :title => 'foobarbaz'
    page.node.update_attributes(:custom_url_suffix => 'test')
    assert_equal 'test', page.node.custom_url_alias
  end
  
  def test_should_append_custom_url_suffix_to_parent_url_alias_if_node_has_parent
    wa = WeblogArchive.create(:parent => @root_node, :title => 'weblogs', :description => 'weblogs')
    parent_node_alias = wa.node.url_alias
    w = wa.weblogs.create(:parent => wa.node, :user => @arthur, :title => 'foobar', :description => 'foobar')
    w.node.update_attributes(:custom_url_suffix => 'test')
    assert_equal "#{parent_node_alias}/test", w.node.custom_url_alias
  end
  
  def test_should_set_custom_url_alias_to_custom_url_suffix_if_custom_url_suffix_starts_with_forward_slash
    wa = WeblogArchive.create(:parent => @root_node, :title => 'weblogs', :description => 'weblogs')
    w = wa.weblogs.create(:parent => wa.node, :user => @arthur, :title => 'foobar', :description => 'foobar')
    w.node.update_attributes(:custom_url_suffix => '/test')
    assert_equal "test", w.node.custom_url_alias
  end
  
  def test_should_set_custom_url_alias_to_unique_custom_url_suffix_if_custom_url_suffix_starts_with_forward_slash
    page = create_page :title => 'foobarbaz'
    page.node.update_attributes(:custom_url_suffix => '/test')
    assert_equal 'test', page.node.custom_url_alias
    
    wa = WeblogArchive.create(:parent => @root_node, :title => 'weblogs', :description => 'weblogs')
    w = wa.weblogs.create(:parent => wa.node, :user => @arthur, :title => 'foobar', :description => 'foobar')
    w.node.update_attributes(:custom_url_suffix => '/test')
    assert_equal "test-1", w.node.custom_url_alias
  end
  
  def test_should_update_url_alias_after_moving_node
    n = create_page.node
    assert_equal(@root_node, n.parent)
    assert_equal 'foo', n.url_alias
    n.move_to_child_of @economie_section_node
    assert_equal "#{@economie_section_node.url_alias}/foo", n.url_alias
  end

  def test_should_reappend_custom_url_suffix_after_moving_node
    n = create_page.node
    assert_equal(@root_node, n.parent)
    n.update_attributes(:custom_url_suffix => 'bar')
    assert_equal 'bar', n.custom_url_alias
    n.move_to_child_of @economie_section_node
    assert_equal "#{@economie_section_node.url_alias}/bar", n.custom_url_alias
  end
  
  def test_should_set_custom_url_alias_to_custom_url_suffix_after_moving_node_if_custom_url_suffix_starts_with_forward_slash
    n = create_page.node
    assert_equal(@root_node, n.parent)
    n.update_attributes(:custom_url_suffix => '/bar')
    assert_equal 'bar', n.custom_url_alias
    n.move_to_child_of @economie_section_node
    assert_equal 'bar', n.custom_url_alias
  end
  
  def test_url_alias_length_restrictions
    cn = create_page
    cn.node.url_alias = "a"
    assert !cn.node.valid?
    assert cn.node.errors.on(:url_alias)
    cn.node.url_alias = "a" * 2
    assert cn.node.valid?
    assert !cn.node.errors.on(:url_alias)
    cn.node.url_alias = "a" * Node::MAXIMUM_URL_ALIAS_LENGTH
    assert cn.node.valid?
    assert !cn.node.errors.on(:url_alias)
    cn.node.url_alias = "a" * (Node::MAXIMUM_URL_ALIAS_LENGTH + 1)
    assert !cn.node.valid?
    assert cn.node.errors.on(:url_alias)
  end
  
  def test_custom_url_alias_length_restrictions
    cn = create_page
    cn.node.custom_url_alias = "a"
    assert !cn.node.valid?
    assert cn.node.errors.on(:custom_url_alias)
    cn.node.custom_url_alias = "a" * 2
    assert cn.node.valid?
    assert !cn.node.errors.on(:custom_url_alias)
    cn.node.custom_url_alias = "a" * Node::MAXIMUM_URL_ALIAS_LENGTH
    assert cn.node.valid?
    assert !cn.node.errors.on(:custom_url_alias)
    cn.node.custom_url_alias = "a" * (Node::MAXIMUM_URL_ALIAS_LENGTH + 1)
    assert !cn.node.valid?
    assert cn.node.errors.on(:custom_url_alias)
  end
  
protected

  def create_page(options = {})
    Page.create({ :user => @arthur, :parent => nodes(:root_section_node), :title => 'foo', :preamble => 'xuu', :body => 'bar', :expires_on => 1.day.from_now.to_date }.merge(options)).reload
  end

end

