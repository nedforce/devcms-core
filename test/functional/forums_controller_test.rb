require File.dirname(__FILE__) + '/../test_helper'

class ForumsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_forum
    get :show, :id => forums(:bewoners_forum).id
    assert_response :success
    assert assigns(:forum)
    assert_equal nodes(:bewoners_forum_node), assigns(:node)
  end
  
end
