require File.expand_path('../../test_helper.rb', __FILE__)

class TopHitsPagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_top_hits_page
    get :show, :id => top_hits_pages(:top_ten_page)
    assert_response :success
    assert assigns(:top_hits_page)
    assert_equal nodes(:top_ten_page_node), assigns(:node)
  end
end
