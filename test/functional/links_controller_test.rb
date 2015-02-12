require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +LinksController+.
class LinksControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'show should issue internal redirect for internal link' do
    get :show, id: links(:internal_link).id
    assert_redirected_to content_node_path(links(:internal_link).linked_node)
  end

  test 'show should issue external redirect for external link' do
    get :show, id: links(:external_link).id
    assert_redirected_to links(:external_link).url
  end
end
