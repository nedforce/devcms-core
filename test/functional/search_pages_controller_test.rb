require File.dirname(__FILE__) + '/../test_helper'

class SearchPagesControllerTest < ActionController::TestCase

  def test_should_redirect_to_search_with_search_parameters
    get :show, :id => search_pages(:standard_search_page), :q => 'test'
    assert_redirected_to search_url(:q => 'test', :top_node => search_pages(:standard_search_page).node.parent.id)
  end
end

