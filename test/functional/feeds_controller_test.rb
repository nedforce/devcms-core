require File.dirname(__FILE__) + '/../test_helper'

class FeedsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_feed
    puts "Test broken (libtidy error).."
    # get :show, :id => feeds(:nedforce_feed).id
    #   assert_response :success, @response.body
    #   assert assigns(:feed)
    #   assert_equal nodes(:nedforce_feed_node), assigns(:node)
  end
  
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
end
