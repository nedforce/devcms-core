require File.expand_path('../../test_helper.rb', __FILE__)

# This test might not work when running all tests using 'rake test' due to the fact that
# the exceptions middleware is not properly initialized in that case.
class RewriteTest < ActionController::IntegrationTest
  fixtures :nodes, :pages, :news_archives, :news_items, :images

  setup do
    @site = Site.first
    @site.update_attribute(:domain, 'www.example.com')
  end

  def test_should_rewrite_to_site_node
    get '/'
    assert_equal @site.frontpage_node, assigns(:node)
  end

  def test_should_rewrite_to_site_node_print_preview
    get '/?layout=print'
    assert_equal @site.frontpage_node, assigns(:node)
    assert response.body.include?('Afdrukken:')
  end

  def test_should_not_rewrite_for_unknown_domain
    @site.update_attribute(:domain, 'www.otherdomain.com')
    get '/'
    assert_response :redirect
  end

  def test_should_rewrite_finds_by_node_id
    @node = Node.root.descendants.with_content_type('Section').all.sample
    get "/content/#{@node.id}"
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  def test_should_rewrite_finds_by_url_alias
    @node = Page.includes(:node).where('nodes.url_alias is not null').first!.node
    get @node.url_alias
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  def test_should_rewrite_finds_by_custom_url_alias
    @node = Page.all.sample.node
    assert @node.update_attributes(:custom_url_suffix => 'dobedobedo'), @node.errors.full_messages.to_sentence
    get '/' + @node.custom_url_alias
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  def test_should_remove_matched_custom_url_part
    @node = Page.all.sample.node
    assert @node.update_attributes(:custom_url_suffix => '/foobar'), @node.errors.full_messages.to_sentence
    assert_equal 'foobar', @node.reload.custom_url_alias
    get '/' + @node.custom_url_alias
    assert_equal "/pages/#{@node.content_id}", request.path
  end

  def test_should_remove_matched_url_part
    @node =  Node.with_content_type('Page').where('nodes.url_alias is not null').first
    get '/' + @node.url_alias
    assert_equal "/pages/#{@node.content_id}", request.path
  end

  def test_should_not_rewrite_with_remaining_slugs
    @node = Page.first.node
    @node.set_url_alias true
    @node.save
    get @node.url_alias + '/1/2013'
    assert_response :not_found
  end

  def test_should_prefer_longest_matched_url_alias
    @node = nodes(:devcms_news_item_voor_vorig_jaar_node)
    @node.set_url_alias true
    @node.save
    get @node.url_alias
    assert_equal @node, assigns(:node)
  end

  def test_should_rewrite_with_action
    @node = Node.root.descendants.with_content_type('Section').all.sample
    @node.set_url_alias true
    @node.save
    get @node.url_alias + '/changes.atom'
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  def test_should_not_rewrite_for_news_archive_archive_with_invalid_date
    @node = NewsArchive.first.node
    @node.set_url_alias true
    @node.save
    get @node.url_alias + '/bla/bla'
    assert_response :not_found
  end
end
