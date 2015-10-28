require File.expand_path('../../test_helper.rb', __FILE__)

class SearchPagesControllerTest < ActionController::TestCase
  test 'should redirect to search with search parameters' do
    get :show, id: search_pages(:standard_search_page), q: 'test'

    assert_redirected_to search_url(q: 'test', search_scope: "node_#{search_pages(:standard_search_page).node.parent.id}")
  end
end
