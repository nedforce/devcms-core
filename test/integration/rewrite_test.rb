require File.expand_path('../../test_helper.rb', __FILE__)

# This test might not work when running all tests using 'rake test' due to the
# fact that the exceptions middleware is not properly initialized in that case.
class RewriteTest < ActionController::IntegrationTest
  fixtures :nodes, :pages, :news_archives, :news_items, :images

  setup do
    @site = Site.first
    @site.update_attribute(:domain, 'www.example.com')
  end

  test 'should rewrite to site node' do
    get '/'
    assert_equal @site.frontpage_node, assigns(:node)
  end

  test 'should rewrite to site node print preview' do
    get '/?layout=print'
    assert_equal @site.frontpage_node, assigns(:node)
    assert response.body.include?('Afdrukken:')
  end

  test 'should not rewrite for unknown domain' do
    @site.update_attribute(:domain, 'www.otherdomain.com')
    get '/'
    assert_response :redirect
  end

  test 'should rewrite finds by node id' do
    @node = Node.root.descendants.with_content_type('Section').all.sample
    get "/content/#{@node.id}"
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  test 'should rewrite finds by url alias' do
    @node = Page.includes(:node).where('nodes.url_alias is not null').first!.node
    get @node.url_alias
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  test 'should rewrite finds by custom url alias' do
    @node = Page.all.sample.node
    assert @node.update_attributes(custom_url_suffix: 'dobedobedo'), @node.errors.full_messages.to_sentence
    get '/' + @node.custom_url_alias
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  test 'should remove matched custom url part' do
    @node = Page.all.sample.node
    assert @node.update_attributes(custom_url_suffix: '/foobar'), @node.errors.full_messages.to_sentence
    assert_equal 'foobar', @node.reload.custom_url_alias
    get '/' + @node.custom_url_alias
    assert_equal "/pages/#{@node.content_id}", request.path
  end

  test 'should remove matched url part' do
    @node = Node.with_content_type('Page').where('nodes.url_alias is not null').first
    get '/' + @node.url_alias
    assert_equal "/pages/#{@node.content_id}", request.path
  end

  test 'should not rewrite with remaining slugs' do
    @node = Page.first.node
    @node.set_url_alias true
    @node.save
    get @node.url_alias + '/1/2013'
    assert_response :not_found
  end

  test 'should prefer longest matched url alias' do
    @node = nodes(:devcms_news_item_voor_vorig_jaar_node)
    @node.set_url_alias true
    @node.save
    get @node.url_alias
    assert_equal @node, assigns(:node)
  end

  test 'should rewrite with action' do
    @node = Node.root.descendants.with_content_type('Section').all.sample
    @node.set_url_alias true
    @node.save
    get @node.url_alias + '/changes.atom'
    assert_equal @node, assigns(:node)
    assert response.body.include?(@node.content.title)
  end

  test 'should not rewrite for news archive with invalid date' do
    @node = NewsArchive.first.node
    @node.set_url_alias true
    @node.save
    get @node.url_alias + '/bla/bla'
    assert_response :not_found
  end
end
