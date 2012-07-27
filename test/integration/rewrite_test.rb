require File.expand_path('../../test_helper.rb', __FILE__)

# This test might not work when running all tests using 'rake test' due to the fact that 
# the exceptions middleware is not properly initialized in that case.
class RewriteTest < ActionController::IntegrationTest
  fixtures :nodes, :pages 
  
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
    @node = Section.all.sample.node
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
    @node.update_attribute(:custom_url_alias, 'dobedobedo')
    get '/' + @node.custom_url_alias
    assert_equal @node, assigns(:node)    
    assert response.body.include?(@node.content.title)
  end     


end
