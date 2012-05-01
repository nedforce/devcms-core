require File.expand_path('../../test_helper.rb', __FILE__)

class SearchPagesControllerTest < ActionController::TestCase

  def test_should_redirect_to_search_with_search_parameters
    get :show, :id => search_pages(:standard_search_page), :q => 'test'
    assert_redirected_to search_url(:q => 'test', :search_scope => "node_#{search_pages(:standard_search_page).node.parent.id}")
  end
end

