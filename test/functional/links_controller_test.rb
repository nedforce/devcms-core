require File.dirname(__FILE__) + '/../test_helper'

class LinksControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_show_should_issue_internal_redirect_for_internal_link
    get :show, :id => links(:internal_link).id
    assert_redirected_to delegated_path(links(:internal_link).linked_node)
  end
  
  def test_show_should_issue_external_redirect_for_external_link
    get :show, :id => links(:external_link).id
    assert_redirected_to links(:external_link).url
  end
  
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
  
end
