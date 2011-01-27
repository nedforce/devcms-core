require File.dirname(__FILE__) + '/../test_helper'

class CombinedCalendarsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_combined_calendar
    get :show, :id => combined_calendars(:combined_calendar).id
    assert_response :success
    assert assigns(:calendar)
    assert_equal nodes(:combined_calendar_node), assigns(:node)
  end
  
  def test_should_show_calendar_atom
    get :show, :id => combined_calendars(:combined_calendar).id, :format => 'atom'
    assert_response :success
  end

  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_get_atom_tomorrow
    get :tomorrow, :id => combined_calendars(:combined_calendar).id, :format => 'atom'
    assert_response :success
  end
  
end
