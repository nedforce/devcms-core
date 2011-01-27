require File.dirname(__FILE__) + '/../test_helper'

class MonitControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_get_heartbeat
    get :heartbeat
    assert_response :success
  end
  
end
