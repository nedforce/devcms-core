require File.dirname(__FILE__) + '/../test_helper'

class PagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_page
    get :show, :id => pages(:help_page).id
    
    assert_response :success
    assert assigns(:page)
    assert_equal nodes(:help_page_node), assigns(:node)
  end

  def test_should_increment_hits_on_show
    page = pages(:help_page)
    old_hits = page.node.hits
    get :show, :id => page
    assert_equal old_hits + 1, page.node.reload.hits
  end
  
  def test_should_render_404_if_hidden_for_user
    get :show, :id => pages(:hidden_page).id
    assert_redirected_to :controller => :errors, :action => :error_404
  end
  
end
