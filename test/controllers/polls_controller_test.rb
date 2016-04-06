require File.expand_path('../../test_helper.rb', __FILE__)

class PollsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should get show' do
    p = polls(:healthcare_poll)
    get :show, id: p.id

    assert_response :success
    assert_equal p, assigns(:poll)
    assert assigns(:earlier_questions)
    refute assigns(:earlier_questions).include?(assigns(:question))
  end
end
