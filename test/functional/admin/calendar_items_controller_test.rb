require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CalendarItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @calendar_item = events(:events_calendar_item_one)
  end
  
  def test_should_render_404_if_not_found
    login_as :sjoerd
        
    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_show_calendar_item
    login_as :sjoerd
    
    get :show, :id => @calendar_item
    assert assigns(:calendar_item)
    assert_response :success    
    assert_equal nodes(:events_calendar_item_one_node), assigns(:node)
  end
  
  def test_should_get_previous
    @calendar_item.create_approved_version

    login_as :sjoerd

    get :previous, :id => @calendar_item
    assert_response :success
    assert assigns(:calendar_item)
  end
 
  def test_should_render_404_if_not_found
    login_as :sjoerd
    
    get :show, :id => -1
    assert_response :not_found
  end  
  
  def test_should_get_new
    login_as :sjoerd
    
    get :new, :parent_node_id => nodes(:events_calendar_node).id
    assert_response :success
    assert assigns(:calendar_item)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:events_calendar_node).id, :calendar_item => { :title => 'foo' }
    assert_response :success
    assert assigns(:calendar_item)
    assert_equal 'foo', assigns(:calendar_item).title
  end
  
  def test_should_create_calendar_item
    login_as :sjoerd
    
    assert_difference('CalendarItem.count', 1) do
      create_calendar_item_request
      assert_response :success
      assert !assigns(:calendar_item).new_record?, :message => assigns(:calendar_item).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('CalendarItem.count') do
      create_calendar_item_request({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:calendar_item).new_record?
      assert_equal 'foobar', assigns(:calendar_item).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('CalendarItem.count') do
      create_calendar_item_request({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:calendar_item).new_record?
      assert assigns(:calendar_item).errors.on(:title)
      assert_template 'new'
    end
  end
  
  def test_should_require_title
    login_as :sjoerd
    
    assert_no_difference('CalendarItem.count') do
      create_calendar_item_request(:title => nil)
    end
    
    assert_response :unprocessable_entity
    assert assigns(:calendar_item).new_record?
    assert assigns(:calendar_item).errors.on(:title)
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => events(:events_calendar_item_one).id
    assert_response :success
    assert assigns(:calendar_item)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => events(:events_calendar_item_one).id, :calendar_item => { :title => 'foo' }
    assert_response :success
    assert assigns(:calendar_item)
    assert_equal 'foo', assigns(:calendar_item).title
  end
  
  def test_should_update_calendar_item
    login_as :sjoerd
    
    put :update, :id => events(:events_calendar_item_one).id, :calendar_item => { :title => 'updated title', :body => 'updated body' }
    
    assert_response :success
    assert_equal 'updated title', assigns(:calendar_item).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    calendar_item = events(:events_calendar_item_one)
    old_title = calendar_item.title
    put :update, :id => calendar_item, :calendar_item => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:calendar_item).title
    assert_equal old_title, calendar_item.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    calendar_item = events(:events_calendar_item_one)
    old_title = calendar_item.title
    put :update, :id => calendar_item, :calendar_item => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:calendar_item).errors.on(:title)
    assert_equal old_title, calendar_item.reload.title
    assert_template 'edit'
  end
  
  def test_should_not_update_calendar_item_with_invalid_title
    login_as :sjoerd
    
    old_title = events(:events_calendar_item_one).title
    put :update, :id => events(:events_calendar_item_one).id, :calendar_item => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:calendar_item).errors.on(:title)
    assert_equal old_title, events(:events_calendar_item_one).reload.title
  end
  
  def test_should_require_roles
    assert_user_can_access :arthur, [:new, :create], {:parent_node_id => nodes(:events_calendar_node).id}
    assert_user_cant_access :final_editor, [:new, :create], {:parent_node_id => nodes(:events_calendar_node).id}
    assert_user_cant_access :editor, [:new, :create], {:parent_node_id => nodes(:events_calendar_node).id}
    assert_user_can_access :arthur, [:update, :edit, :destroy], {:id => events(:events_calendar_item_one).id}
    assert_user_cant_access :final_editor, [:update, :edit, :destroy], {:id => events(:events_calendar_item_one).id}
    assert_user_cant_access :editor, [:update, :edit, :destroy], {:id => events(:events_calendar_item_one).id}
  end

  def test_should_delete_non_repeating_calender_item
    login_as :sjoerd

    assert_difference 'CalendarItem.count', -1 do
      delete :destroy, :id => events(:events_calendar_item_one)
      assert_response :success
    end 
  end

  def test_should_delete_repeating_calender_item_and_its_repetitions
    login_as :sjoerd
    
    now = Time.now

    ci = create_repeating_calendar_item({
      :start_time => now,
      :end_time => now + 1.hours,
      :repeating => true,
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
      :repeat_end => (now + 1.week).to_date
    })

    created_items_count = count_number_of_created_calendar_items(ci.start_time.to_date, ci.repeat_end, 1.days)

    assert_difference 'CalendarItem.count', -created_items_count do
      delete :destroy, :id => ci
      assert_response :success
    end
  end

protected
  
  def create_calendar_item_request(attributes = {}, options = {})
    now = Time.now
    
    post :create, { :parent_node_id => nodes(:events_calendar_node).id, :calendar_item => { :title => 'new title', :repeating => false, :date=> now.strftime("%d-%m-%Y"), :start_time => now.strftime("%H:%M"), :end_time => (now + 1.hour).strftime("%H:%M") }.merge(attributes)}.merge(options)
  end

  def create_calendar_item(options = {})
    now = Time.now
    CalendarItem.create({:parent => calendars(:events_calendar).node, :repeating => false, :title => "New event", :date=> now, :start_time => now, :end_time => (now + 1.hour) }.merge(options))
  end

  def create_repeating_calendar_item(options = {})
    create_calendar_item({
      :repeating => true,
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
      :repeat_end => 1.month.from_now.to_date
    }.merge(options))
  end

  def count_number_of_created_calendar_items(start_date, end_date, span)
    amount = 0
    next_date = start_date

    while (next_date <= end_date)
      amount += 1
      next_date += span
    end

    amount
  end
  
end