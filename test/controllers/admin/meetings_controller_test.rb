require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::MeetingsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @meeting = events(:meetings_calendar_meeting_one)
  end

  def test_should_show_meeting
    login_as :sjoerd

    get :show, :id => @meeting
    assert assigns(:meeting)
    assert_response :success
    assert_equal nodes(:meetings_calendar_meeting_one_node), assigns(:node)
  end

  test 'should get previous' do
    @meeting.save :user => User.find_by_login('editor')

    login_as :sjoerd

    get :previous, :id => @meeting
    assert_response :success
    assert assigns(:meeting)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:events_calendar_node).id
    assert_response :success
    assert assigns(:meeting)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:events_calendar_node).id, :meeting => { :title => 'foo' }
    assert_response :success
    assert assigns(:meeting)
    assert_equal 'foo', assigns(:meeting).title
  end

  def test_should_create_meeting
    login_as :sjoerd

    assert_difference('Meeting.count', 1) do
      create_meeting_request
      assert_response :success
      refute assigns(:meeting).new_record?, assigns(:meeting).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Meeting.count') do
      create_meeting_request({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:meeting).new_record?
      assert_equal 'foobar', assigns(:meeting).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Meeting.count') do
      create_meeting_request({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:meeting).new_record?
      assert assigns(:meeting).errors[:title].any?
      assert_template 'new'
    end
  end

  test 'should require title' do
    login_as :sjoerd

    assert_no_difference('Meeting.count') do
      create_meeting_request(:title => nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:meeting).new_record?
    assert assigns(:meeting).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, :id => @meeting
    assert_response :success
    assert assigns(:meeting)
  end

  test 'should get edit with params' do
    login_as :sjoerd

    get :edit, :id => @meeting, :meeting => { :title => 'foo' }
    assert_response :success
    assert assigns(:meeting)
    assert_equal 'foo', assigns(:meeting).title
  end

  def test_should_update_meeting
    login_as :sjoerd

    put :update, :id => @meeting, :meeting => { :title => 'updated title', :body => 'updated body' }

    assert_response :success
    assert_equal 'updated title', assigns(:meeting).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    old_title = @meeting.title
    put :update, :id => @meeting, :meeting => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:meeting).title
    assert_equal old_title, @meeting.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    old_title = @meeting.title
    put :update, :id => @meeting, :meeting => { :title => nil }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:meeting).errors[:title].any?
    assert_equal old_title, @meeting.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_meeting_with_invalid_title
    login_as :sjoerd

    old_title = @meeting.title
    put :update, :id => @meeting, :meeting => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:meeting).errors[:title].any?
    assert_equal old_title, @meeting.reload.title
  end

  def test_should_delete_non_repeating_calender_item
    login_as :sjoerd

    assert_difference 'Meeting.count', -1 do
      delete :destroy, :id => @meeting
      assert_response :success
    end
  end

  def test_should_delete_repeating_meeting_and_its_repetitions
    login_as :sjoerd

    now = Time.now

    ci = create_repeating_meeting({
      :start_time => now,
      :end_time => now + 1.hours,
      :repeating => true,
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
      :repeat_end => (now + 1.week).to_date
    })

    created_items_count = count_number_of_created_meetings(ci.start_time.to_date, ci.repeat_end, 1.days)

    assert_difference 'Meeting.count', -created_items_count do
      delete :destroy, :id => ci
      assert_response :success
    end
  end

protected

  def create_meeting_request(attributes = {}, options = {})
    now = Time.now

    post :create, { :parent_node_id => nodes(:events_calendar_node).id, :meeting => { :title => 'new title', :repeating => false, :start_time => now.strftime("%H:%M"), :date => now.strftime("%d-%m-%Y"), :end_time => (now + 1.hour).strftime("%H:%M"), :meeting_category_name => 'problem' }.merge(attributes) }.merge(options)
  end

  def create_meeting(options = {})
    now = Time.now
    Meeting.create({ :parent => calendars(:events_calendar).node, :repeating => false, :title => 'New event', :start_time => now, :end_time => now + 1.hour, :meeting_category_name => 'problem' }.merge(options))
  end

  def create_repeating_meeting(options = {})
    create_meeting({
      :repeating => true,
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
      :repeat_end => 1.month.from_now.to_date
    }.merge(options))
  end

  def count_number_of_created_meetings(start_date, end_date, span)
    amount = 0
    next_date = start_date

    while (next_date <= end_date)
      amount += 1
      next_date += span
    end

    amount
  end
end
