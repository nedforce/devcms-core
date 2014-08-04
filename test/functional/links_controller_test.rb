require File.expand_path('../../test_helper.rb', __FILE__)

class LinksControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_show_should_issue_internal_redirect_for_internal_link
    get :show, :id => links(:internal_link).id
    assert_redirected_to content_node_path(links(:internal_link).linked_node)
  end

  def test_show_should_issue_external_redirect_for_external_link
    get :show, :id => links(:external_link).id
    assert_redirected_to links(:external_link).url
  end
end
