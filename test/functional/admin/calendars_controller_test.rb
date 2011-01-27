require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CalendarsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_show_calendar
    login_as :sjoerd

    get :show, :id => calendars(:events_calendar).id
    assert_response :success
    assert assigns(:calendar)
    assert_equal calendars(:events_calendar).node, assigns(:node)
  end  

  def test_should_get_index
    login_as :sjoerd

    get :index, :node => nodes(:events_calendar_node).id
    assert_response :success
    assert assigns(:calendar_node)
  end

  def test_should_get_index_for_year
    login_as :sjoerd

    get :index, :super_node => nodes(:events_calendar_node).id, :year => '2008'
    assert_response :success
    assert assigns(:calendar_node)
    assert assigns(:year)
  end

  def test_should_get_index_for_year_and_month
    login_as :sjoerd

    get :index, :super_node => nodes(:events_calendar_node).id, :year => '2008', :month => '1'
    assert_response :success
    assert assigns(:calendar_node)
    assert assigns(:year)
    assert assigns(:month)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:calendar)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :calendar => { :title => 'foo' }
    assert_response :success
    assert assigns(:calendar)
    assert_equal 'foo', assigns(:calendar).title
  end

  def test_should_create_calendar
    login_as :sjoerd

    assert_difference('Calendar.count') do
      create_calendar
      assert_response :success
      assert !assigns(:calendar).new_record?, :message => assigns(:calendar).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Calendar.count') do
      create_calendar({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:calendar).new_record?
      assert_equal 'foobar', assigns(:calendar).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Calendar.count') do
      create_calendar({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:calendar).new_record?
      assert assigns(:calendar).errors.on(:title)
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('Calendar.count') do
      create_calendar({ :title => nil })
    end

    assert_response :unprocessable_entity
    assert assigns(:calendar).new_record?
    assert assigns(:calendar).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => calendars(:events_calendar).id
    assert_response :success
    assert assigns(:calendar)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => calendars(:events_calendar).id, :calendar => { :title => 'foo' }
    assert_response :success
    assert assigns(:calendar)
    assert_equal 'foo', assigns(:calendar).title
  end

  def test_should_update_calendar
    login_as :sjoerd

    put :update, :id => calendars(:events_calendar).id, :calendar => { :title => 'updated title', :description => 'updated_body' }

    assert_response :success
    assert_equal 'updated title', assigns(:calendar).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    calendar  = calendars(:events_calendar)
    old_title = calendar.title
    put :update, :id => calendar, :calendar => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:calendar).title
    assert_equal old_title, calendar.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    calendar  = calendars(:events_calendar)
    old_title = calendar.title
    put :update, :id => calendar, :calendar => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:calendar).errors.on(:title)
    assert_equal old_title, calendar.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_calendar
    login_as :sjoerd

    put :update, :id => calendars(:events_calendar).id, :calendar => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:calendar).errors.on(:title)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       [ :new, :create ],  { :parent_node_id => nodes(:root_section_node).id }
    assert_user_can_access  :final_editor, [ :new, :create ],  { :parent_node_id => nodes(:economie_section_node).id }
    assert_user_cant_access :editor,       [ :new, :create ],  { :parent_node_id => nodes(:devcms_news_node).id }
    assert_user_can_access  :arthur,       [ :update, :edit ], { :id => calendars(:events_calendar).id }
    assert_user_cant_access :final_editor, [ :update, :edit ], { :id => calendars(:events_calendar).id }
    assert_user_cant_access :editor,       [ :update, :edit ], { :id => calendars(:events_calendar).id }
  end

protected

  def create_calendar(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :calendar => { :title => 'Amazing phenomena calendar', :description => 'Wow!' }.merge(attributes) }.merge(options)
  end
end
