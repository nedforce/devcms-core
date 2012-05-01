require File.expand_path('../../test_helper.rb', __FILE__)

class MonitControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_get_heartbeat
    get :heartbeat
    assert_response :success
  end
  
end
