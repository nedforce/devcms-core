require File.expand_path('../../test_helper.rb', __FILE__)

class EventsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show calendar item' do
    get :show, id: events(:events_calendar_item_one).id
    assert_response :success
    assert assigns(:calendar_item)
    assert_equal nodes(:events_calendar_item_one_node), assigns(:node)
  end

  test 'should show meeting' do
    get :show, id: events(:meetings_calendar_meeting_one).id
    assert_response :success
    assert assigns(:calendar_item)
    assert_equal nodes(:meetings_calendar_meeting_one_node), assigns(:node)
  end
end
