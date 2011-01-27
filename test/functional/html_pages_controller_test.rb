require File.dirname(__FILE__) + '/../test_helper'

class HtmlPagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_html_page
    get :show, :id => html_pages(:about_html_page)
    assert_response :success
    assert assigns(:html_page)
    assert_equal nodes(:about_html_page_node), assigns(:node)
  end
  
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
  
end
