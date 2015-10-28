require File.expand_path('../../test_helper.rb', __FILE__)

class NodeURLAliasTest < ActiveSupport::TestCase
  setup do
    @arthur                = users(:arthur)
    @root_node             = nodes(:root_section_node)
    @about_page_node       = nodes(:about_page_node)
    @economie_section_node = nodes(:economie_section_node)
  end

  test 'should create url alias' do
    cn = create_page
    assert_equal 'foo', cn.node.url_alias
  end

  test 'should create custom url alias' do
    cn = create_page
    cn.node.update_attributes(custom_url_suffix: 'test')
    assert_equal 'test', cn.node.custom_url_alias
  end

  def test_should_create_url_alias_for_frontpage_child
    ni = NewsItem.create({ :parent => nodes(:devcms_news_node), :title => 'foo', :preamble => 'xuu', :body => 'bar', :publication_start_date => '2008-05-20 12:00' })
    assert_equal '2008/5/20/foo', ni.node.url_alias
  end

  def test_should_remove_trailing_slashes_from_url_aliases
    page = Page.create({ :parent => nodes(:root_section_node), :title => 'foo/', :preamble => 'xuu', :body => 'bar', :expires_on => 1.day.from_now.to_date, :publication_start_date => '2008-05-20 12:00' })
    assert_equal 'foo', page.node.url_alias
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

    assert cn.update_attributes(:title => 'foobar')
    assert_equal 'foobar', cn.node.reload.url_alias
  end

  def test_should_change_url_alias_when_title_changes_for_non_unique_title
    cn = create_page
    assert_equal 'foo', cn.node.url_alias

    cn2 = create_page :title => 'bar'
    assert_equal 'bar', cn2.node.url_alias

    cn2.update_attributes(:title => 'foo')
    assert_equal 'foo-1', Node.find(cn2.node.id).url_alias
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

    assert_raises ActiveModel::MassAssignmentSecurity::Error do
      cn.node.update_attributes(:url_alias => 'bar')
    end

    assert_equal 'foo', cn.node.url_alias
  end

  def test_should_protect_custom_url_alias
    cn = create_page
    cn.node.update_attributes(:custom_url_suffix => 'foo')
    assert_equal 'foo', cn.node.custom_url_alias

    assert_raises ActiveModel::MassAssignmentSecurity::Error do
      cn.node.update_attributes(:custom_url_alias => 'bar')
    end

    assert_equal 'foo', cn.node.custom_url_alias
  end

  def test_should_append_parent_url_alias_if_node_has_parent
    na = NewsArchive.create(:parent => @root_node, :title => 'news', :description => 'news')
    parent_node_alias = na.node.url_alias
    ni = na.news_items.create(:parent => na.node, :user => @arthur, :title => 'foobar', :body => 'foobar')

    special_ni_url_alias = "/#{Date.today.strftime("%Y/%-m/%-d")}"

    assert_equal "#{parent_node_alias}#{special_ni_url_alias}/foobar", ni.node.url_alias
  end

  def test_should_set_custom_url_alias_to_custom_url_suffix_if_node_has_no_parent
    page = create_page :title => 'foobarbaz'
    page.node.update_attributes(:custom_url_suffix => 'test')

    assert_equal 'test', page.node.custom_url_alias
  end

  def test_should_append_custom_url_suffix_to_parent_url_alias_if_node_has_parent
    na = NewsArchive.create(:parent => @root_node, :title => 'news', :description => 'news')
    parent_node_alias = na.node.url_alias
    ni = na.news_items.create(:parent => na.node, :user => @arthur, :title => 'foobar', :body => 'foobar')
    ni.node.update_attributes(:custom_url_suffix => 'test')

    assert_equal "#{parent_node_alias}/test", ni.node.custom_url_alias
  end

  test 'should set custom_url_alias to custom_url_suffix if custom_url_suffix starts with forward slash' do
    na = NewsArchive.create(parent: @root_node, title: 'news', description: 'news')
    ni = na.news_items.create(parent: na.node, user: @arthur, title: 'foobar', body: 'foobar')
    ni.node.update_attributes(custom_url_suffix: '/test')

    assert_equal 'test', ni.node.custom_url_alias
  end

  test 'should set custom_url_alias to unique custom_url_suffix if custom_url_suffix starts with forward slash' do
    page = create_page title: 'foobarbaz'
    page.node.update_attributes(custom_url_suffix: '/test')
    assert_equal 'test', page.node.custom_url_alias

    na = NewsArchive.create(parent: @root_node, title: 'Test news', description: 'Test news')
    ni = na.news_items.create(parent: na.node, user: @arthur, title: 'foobar', body: 'foobar')
    ni.node.update_attributes(custom_url_suffix: '/test')
    assert_equal 'test-1', ni.node.custom_url_alias
  end

  def test_should_update_url_alias_after_moving_node
    n = create_page.node
    assert_equal(@root_node, n.parent)
    assert_equal 'foo', n.url_alias
    n.move_to_child_of @economie_section_node
    assert_equal "#{@economie_section_node.url_alias}/foo", n.reload.url_alias
  end

  def test_should_reappend_custom_url_suffix_after_moving_node
    n = create_page.node
    assert_equal(@root_node, n.parent)
    n.update_attributes(:custom_url_suffix => 'bar')
    assert_equal 'bar', n.custom_url_alias
    n.move_to_child_of @economie_section_node
    assert_equal "#{@economie_section_node.url_alias}/bar", n.reload.custom_url_alias
  end

  def test_should_set_custom_url_alias_to_custom_url_suffix_after_moving_node_if_custom_url_suffix_starts_with_forward_slash
    n = create_page.node
    assert_equal(@root_node, n.parent)
    n.update_attributes(:custom_url_suffix => '/bar')
    assert_equal 'bar', n.custom_url_alias
    n.move_to_child_of @economie_section_node
    assert_equal 'bar', n.custom_url_alias
  end

  def test_should_update_url_aliases_of_subtree_on_move
    node = nodes(:devcms_news_node)
    Node.root.content.set_frontpage!(nil)
    node.descendants.update_all(:url_alias => 'placeholder')
    assert node.descendants.all? { |n| n.url_alias == 'placeholder' }, 'Should have set all descendants url_aliasses!'
    assert nodes(:economie_section_node).url_alias.size > 1
    node.move_to_child_of nodes(:economie_section_node)
    assert node.descendants.all? { |n| n.url_alias.include? nodes(:economie_section_node).url_alias }, 'Should have prefixed url_aliasses'
  end

  def test_should_update_url_aliases_of_subtree_on_rename
    node = nodes(:devcms_news_node)
    Node.root.content.set_frontpage!(nil)
    node.descendants.update_all(:url_alias => 'placeholder')
    assert node.descendants.all? { |n| n.url_alias == 'placeholder' }, 'Should have set all descendants url_aliasses!'
    node.content.update_attributes :title => 'Nieuwe Nieuws Sectie Naam'
    node.reload
    assert_not_nil node.url_alias
    assert node.descendants.all? { |n| n.url_alias.include? node.url_alias }, 'Should have prefixed url_aliasses'
  end

  def test_url_alias_length_restrictions
    cn = create_page
    cn.node.url_alias = 'a'
    assert !cn.node.valid?
    assert cn.node.errors[:url_alias].any?
    cn.node.url_alias = 'a' * 2
    assert cn.node.valid?
    assert !cn.node.errors[:url_alias].any?
    cn.node.url_alias = 'a' * Node::MAXIMUM_URL_ALIAS_LENGTH
    assert cn.node.valid?
    assert !cn.node.errors[:url_alias].any?
    cn.node.url_alias = 'a' * (Node::MAXIMUM_URL_ALIAS_LENGTH + 1)
    assert !cn.node.valid?
    assert cn.node.errors[:url_alias].any?
  end

  def test_custom_url_alias_length_restrictions
    cn = create_page
    cn.node.custom_url_alias = 'a'
    assert !cn.node.valid?
    assert cn.node.errors[:custom_url_alias].any?
    cn.node.custom_url_alias = 'a' * 2
    assert cn.node.valid?
    assert !cn.node.errors[:custom_url_alias].any?
    cn.node.custom_url_alias = 'a' * Node::MAXIMUM_URL_ALIAS_LENGTH
    assert cn.node.valid?
    assert !cn.node.errors[:custom_url_alias].any?
    cn.node.custom_url_alias = 'a' * (Node::MAXIMUM_URL_ALIAS_LENGTH + 1)
    assert !cn.node.valid?
    assert cn.node.errors[:custom_url_alias].any?
  end

  def test_should_clear_aliases_on_paranoid_destroy
    cn = create_page(:title => 'foobarbaz').node
    assert 'foobarbaz', cn.url_alias
    cn2 = create_page.node
    cn2.url_alias = 'foobarbaz'
    assert cn.valid?
    assert !cn2.valid?
    cn.paranoid_delete!
    assert_nil Page.find_by_id(cn.id)
    assert_equal [], Node.all_including_deleted(:conditions => "url_alias = 'foobarbaz'")
    assert cn2.valid?, cn2.errors.full_messages.to_sentence
  end

  def test_should_require_uniq_url_alias_scoped_by_site
    cn1 = create_page(:title => 'foobarbaz').node
    cn2 = create_page(:parent => nodes(:sub_site_section_node), :title => 'foobarbaz' ).node
    assert cn2.valid?
    assert_equal cn1.url_alias, cn2.url_alias
  end

  def test_should_not_assign_reserved_url_alias
    cn = create_page
    cn.node.url_alias = Rails.application.config.reserved_slugs.first
    assert !cn.node.valid?
    assert cn.node.errors[:url_alias].any?

    cn = create_page(title: Rails.application.config.reserved_slugs.first)
    assert cn.node.valid?
    assert !Rails.application.config.reserved_slugs.include?(cn.node.url_alias)

    cn = create_page(title: Rails.application.config.reserved_slugs.first)
    cn.node.url_alias = 'signup'
    assert !cn.node.valid?
    assert cn.node.errors[:url_alias].any?
  end

  def test_should_clear_custom_alias_with_suffix
    cn = create_page(:title => 'foobarbaz').node
    cn.update_attributes :custom_url_suffix => 'suffix'
    assert_equal 'suffix', cn.custom_url_alias
    cn.update_attributes :custom_url_suffix => ""
    cn.reload
    assert_equal nil, cn.custom_url_alias
  end

protected

  def create_page(options = {})
    Page.create({ :user => @arthur, :parent => nodes(:root_section_node), :title => 'foo', :preamble => 'xuu', :body => 'bar' }.merge(options)).reload
  end
end
