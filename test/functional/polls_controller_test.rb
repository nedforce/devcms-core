require File.dirname(__FILE__) + '/../test_helper'

class PollsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_get_show
    p = polls(:healthcare_poll)
    get :show, :id => p.id
    assert_response :success
    assert_equal p, assigns(:poll)
    assert assigns(:earlier_questions)
    assert !assigns(:earlier_questions).include?(assigns(:question))
  end
  
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
  
end
