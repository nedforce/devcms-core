require File.dirname(__FILE__) + '/../test_helper'

class EventsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_calendar_item
    get :show, :id => events(:events_calendar_item_one).id
    assert_response :success
    assert assigns(:calendar_item)
    assert_equal nodes(:events_calendar_item_one_node), assigns(:node)
  end
  
  def test_should_show_meeting
    get :show, :id => events(:meetings_calendar_meeting_one).id
    assert_response :success
    assert assigns(:calendar_item)
    assert_equal nodes(:meetings_calendar_meeting_one_node), assigns(:node)
  end
end
