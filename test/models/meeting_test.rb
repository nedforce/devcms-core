require File.expand_path('../../test_helper.rb', __FILE__)

class MeetingTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @meetings_calendar             = calendars(:meetings_calendar)
    @meetings_calendar_meeting_one = events(:meetings_calendar_meeting_one)
    @meeting_category              = meeting_categories(:gemeenteraad_meetings)
    @meeting_category_two          = meeting_categories(:adviescommissie_meetings)
  end

  test 'should create meeting' do
    assert_difference 'Meeting.count' do
      meeting = create_meeting
      refute meeting.new_record?, "#{meeting.errors.full_messages.to_sentence}"
    end
  end

  test 'should require meeting category' do
    assert_no_difference 'Meeting.count' do
      meeting = create_meeting(meeting_category: nil)
      assert meeting.errors[:meeting_category].any?
    end
  end

  test 'should update meeting' do
    assert_no_difference 'Meeting.count' do
      @meetings_calendar_meeting_one.title = 'New title'
      assert @meetings_calendar_meeting_one.save(user: users(:arthur))
    end
  end

  test 'should destroy meeting' do
    assert_difference 'Meeting.count', -1 do
      @meetings_calendar_meeting_one.destroy
    end
  end

  def test_meeting_category_name_should_return_nil_if_no_meeting_category_is_associated
    meeting = create_meeting(meeting_category: nil)
    assert_nil meeting.meeting_category_name
  end

  def test_meeting_category_name_should_return_name_of_associated_meeting_category_if_a_meeting_category_is_associated
    meeting = create_meeting
    assert_equal meeting.meeting_category.name, meeting.meeting_category_name
  end

  def test_meeting_category_name_should_associate_existing_meeting_category_on_create
    assert_no_difference('MeetingCategory.count') do
      meeting = create_meeting({ :meeting_category_name => @meeting_category.name, :title => 'New meeting', :start_time => DateTime.now.to_s(:db), :end_time => (DateTime.now + 1.hour).to_s(:db) })
      assert_equal @meeting_category, meeting.meeting_category
    end
  end

  def test_meeting_category_name_should_associate_existing_meeting_category_on_update
    assert_no_difference('MeetingCategory.count') do
      @meetings_calendar_meeting_one.meeting_category_name = @meeting_category_two.name
      @meetings_calendar_meeting_one.save
      assert_equal @meeting_category_two, @meetings_calendar_meeting_one.meeting_category
    end
  end

  def test_meeting_category_name_should_create_new_meeting_category_for_valid_name
    @meetings_calendar_meeting_one.meeting_category_name = 'foo'

    assert_difference('MeetingCategory.count', 1) do
      assert @meetings_calendar_meeting_one.save
    end

    assert_equal MeetingCategory.find_by_name('foo'), @meetings_calendar_meeting_one.meeting_category
  end

  def test_meeting_category_name_should_not_create_new_meeting_category_for_blank_name
    assert_no_difference('MeetingCategory.count') do
      old_meeting_category = @meetings_calendar_meeting_one.meeting_category
      @meetings_calendar_meeting_one.meeting_category_name = nil
      @meetings_calendar_meeting_one.save
      assert_equal old_meeting_category, @meetings_calendar_meeting_one.reload.meeting_category
    end
  end

  test 'meeting category name should not create new meeting category for invalid name' do
    assert_no_difference('MeetingCategory.count') do
      old_meeting_category = @meetings_calendar_meeting_one.meeting_category
      @meetings_calendar_meeting_one.meeting_category_name = ' '
      @meetings_calendar_meeting_one.save
      assert_equal old_meeting_category, @meetings_calendar_meeting_one.reload.meeting_category
    end
  end

  def test_should_not_return_meeting_children_for_menu
    assert @meetings_calendar.node.children.accessible.shown_in_menu.empty?
  end

  def test_should_find_child_agenda_items
    items = @meetings_calendar_meeting_one.agenda_items.accessible

    assert items.include?(agenda_items(:agenda_item_one))
    assert items.include?(agenda_items(:agenda_item_two))
  end

  protected

  def create_meeting(options = {})
    Meeting.create({
      parent: nodes(:meetings_calendar_node),
      repeating: false,
      meeting_category: @meeting_category,
      title: 'New meeting',
      start_time: DateTime.now.to_s(:db),
      end_time: (DateTime.now + 1.hour).to_s(:db)
    }.merge(options))
  end
end
