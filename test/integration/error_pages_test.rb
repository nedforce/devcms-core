require File.dirname(__FILE__) + '/../test_helper'

class ErrorPagesTest < ActionController::IntegrationTest
  fixtures :nodes, :pages

  def test_should_render_custom_404
    Settler.error_page_404.update_attribute(:value, nodes(:help_page_node).url_alias)

    get 'this/page/does/not/exist'
    assert_response :not_found
    assert assigns(:page).node.url_alias, nodes(:help_page_node).url_alias
  end
  
  def test_should_render_default_template_if_no_custom_page_is_set
    Settler.error_page_404.update_attribute(:value, nil)

    get 'this/page/does/not/exist'
    assert_response :not_found
    assert_template 'errors/404'
  end  
  
  def test_should_render_default_template_if_custom_page_is_not_found
    Settler.error_page_404.update_attribute(:value, 'this/custom/error/page/does/not/exist')    

    get 'this/page/does/not/exist'
    assert_response :not_found
    assert_template 'errors/404'
  end
end
