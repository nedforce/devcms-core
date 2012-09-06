require File.expand_path('../../test_helper.rb', __FILE__)

class CalendarsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_calendar
    get :show, :id => calendars(:events_calendar).id
    assert_response :success
    assert assigns(:calendar)
    assert_equal nodes(:events_calendar_node), assigns(:node)
  end
  
  def test_should_show_calendar_atom
    get :show, :id => calendars(:events_calendar).id, :format => 'atom'
    assert_response :success
  end
  
  def test_should_redirect_atom_index
    get :index, :format => 'atom'
    assert_response :redirect
  end
  
  def test_should_get_atom_tomorrow
    get :tomorrow, :id => calendars(:events_calendar).id, :format => 'atom'
    assert_response :success
  end

  def test_should_show_calendar_rss
    get :show, :id => calendars(:events_calendar).id, :format => 'rss'
    assert_response :success
  end
  
  def test_should_redirect_rss_index
    get :index, :format => 'rss'
    assert_response :redirect
  end
  
  def test_should_get_rss_tomorrow
    get :tomorrow, :id => calendars(:events_calendar).id, :format => 'rss'
    assert_response :success
  end
end
