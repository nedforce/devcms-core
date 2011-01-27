require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CombinedCalendarsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_render_404_if_not_found
    login_as :sjoerd
        
    get :show, :id => -1
    assert_response :not_found
  end
  
  def test_should_show_combined_calendar
    login_as :sjoerd
    
    get :show, :id => combined_calendars(:combined_calendar).id
    assert_response :success
    assert assigns(:combined_calendar)
    assert_equal nodes(:combined_calendar_node), assigns(:node)
  end  
  
  def test_should_get_new
    login_as :sjoerd
    
    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:combined_calendar)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :combined_calendar => { :title => 'foo' }
    assert_response :success
    assert assigns(:combined_calendar)
    assert_equal 'foo', assigns(:combined_calendar).title
  end
  
  def test_should_create_calendar
    login_as :sjoerd
    
    assert_difference('CombinedCalendar.count') do
      create_combined_calendar
      assert_response :success
      assert !assigns(:combined_calendar).new_record?, :message => assigns(:combined_calendar).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('CombinedCalendar.count') do
      create_combined_calendar({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:combined_calendar).new_record?
      assert_equal 'foobar', assigns(:combined_calendar).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('CombinedCalendar.count') do
      create_combined_calendar({ :title => nil }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:combined_calendar).new_record?
      assert assigns(:combined_calendar).errors.on(:title)
      assert_template 'new'
    end
  end
  
  def test_should_require_title
    login_as :sjoerd
    
    assert_no_difference('CombinedCalendar.count') do
      create_combined_calendar({:title => nil})
    end
    
    assert_response :success
    assert assigns(:combined_calendar).new_record?
    assert assigns(:combined_calendar).errors.on(:title)
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => combined_calendars(:combined_calendar).id
    assert_response :success
    assert assigns(:combined_calendar)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => combined_calendars(:combined_calendar).id, :combined_calendar => { :title => 'foo' }
    assert_response :success
    assert assigns(:combined_calendar)
    assert_equal 'foo', assigns(:combined_calendar).title
  end
  
  def test_should_update_combined_calendar
    login_as :sjoerd
    
    put :update, :id => combined_calendars(:combined_calendar).id, :combined_calendar => {:title => 'updated title', :description => 'updated_body'}
    
    assert_response :success
    assert_equal 'updated title', assigns(:combined_calendar).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    combined_calendar = combined_calendars(:combined_calendar)
    old_title = combined_calendar.title
    put :update, :id => combined_calendar, :combined_calendar => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:combined_calendar).title
    assert_equal old_title, combined_calendar.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    combined_calendar = combined_calendars(:combined_calendar)
    old_title = combined_calendar.title
    put :update, :id => combined_calendar, :combined_calendar => { :title => nil }, :commit_type => 'preview'

    assert_response :success
    assert assigns(:combined_calendar).errors.on(:title)
    assert_equal old_title, combined_calendar.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_combined_calendar
    login_as :sjoerd
    
    put :update, :id => combined_calendars(:combined_calendar).id, :combined_calendar => {:title => nil}
    assert_response :success
    assert assigns(:combined_calendar).errors.on(:title)
  end
  
  def test_should_require_roles
    assert_user_can_access :arthur, [:new, :create], {:parent_node_id => nodes(:root_section_node).id}
    assert_user_can_access :final_editor, [:new, :create], {:parent_node_id => nodes(:economie_section_node).id}
    assert_user_cant_access :editor, [:new, :create], {:parent_node_id => nodes(:devcms_news_node).id}
    assert_user_can_access :arthur, [:update, :edit], {:id => combined_calendars(:combined_calendar).id}
    assert_user_cant_access :final_editor, [:update, :edit], {:id => combined_calendars(:combined_calendar).id}
    assert_user_cant_access :editor, [:update, :edit], {:id => combined_calendars(:combined_calendar).id}
  end

protected
  
  def create_combined_calendar(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :combined_calendar => { :title => "Amazing combined calendar", :description => "Wow!" }.merge(attributes) }.merge(options)
  end
  
end
