require File.expand_path('../../test_helper.rb', __FILE__)

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

  def test_should_get_atom_tomorrow
    get :tomorrow, :id => combined_calendars(:combined_calendar).id, :format => 'atom'
    assert_response :success
  end

  def test_should_show_calendar_rss
    get :show, :id => combined_calendars(:combined_calendar).id, :format => 'rss'
    assert_response :success
  end

  def test_should_get_rss_tomorrow
    get :tomorrow, :id => combined_calendars(:combined_calendar).id, :format => 'rss'
    assert_response :success
  end
  
end
