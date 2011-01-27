require File.dirname(__FILE__) + '/../test_helper'

class CalendarItemTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @events_calendar = calendars(:events_calendar)
    @events_calendar_item_one = events(:events_calendar_item_one)
    @calendar_item = @events_calendar_item_one
    @arthur = users(:arthur)
  end

  def test_has_repetitions?
    ci = create_calendar_item
    assert !ci.has_repetitions?
  end

  def test_should_create_calendar_item
    assert_difference 'CalendarItem.count' do
      ci = create_calendar_item
      assert '#{ci.start_time.year}/#{ci.start_time.month}/#{ci.start_time.day}/new-event', ci.node.url_alias
    end
  end

  def test_should_require_title
    assert_no_difference 'CalendarItem.count' do
      calendar_item = create_calendar_item(:title => nil)
      assert calendar_item.errors.on(:title)
    end

    assert_no_difference 'CalendarItem.count' do
      calendar_item = create_calendar_item(:title => "  ")
      assert calendar_item.errors.on(:title)
    end
  end

  def test_should_require_start_time
    assert_no_difference 'CalendarItem.count' do
      calendar_item = create_calendar_item(:start_time => nil)
      assert calendar_item.errors.on(:start_time)
    end
  end

  def test_should_force_end_time
    calendar_item = create_calendar_item(:end_time => nil)
    assert_equal calendar_item.start_time + 30.minutes, calendar_item.end_time
  end

  def test_should_require_parent
    assert_no_difference 'CalendarItem.count' do
      calendar_item = create_calendar_item(:parent => nil)
      assert calendar_item.errors.on(:calendar)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'CalendarItem.count', 2 do
      2.times do
        calendar_item = create_calendar_item(:title => 'Non-unique title')
        assert !calendar_item.errors.on(:title)
      end
    end
  end

  def test_should_update_calendar_item
    assert_no_difference 'CalendarItem.count' do
      @events_calendar_item_one.title = 'New title'
      @events_calendar_item_one.start_time = DateTime.now
      @events_calendar_item_one.end_time = DateTime.now + 1.hour
      assert @events_calendar_item_one.save_for_user(users(:arthur))
    end
  end

  def test_should_destroy_calendar_item
    assert_difference "CalendarItem.count", -1 do
      @events_calendar_item_one.destroy
    end
  end

  def test_human_name_does_not_return_nil
    assert_not_nil CalendarItem.human_name
  end

  def test_should_not_return_calendar_item_children_for_menu
    assert @events_calendar.node.accessible_children(:for_menu => true).empty?
  end
  
  def test_should_set_or_update_dynamic_attributes
    event = @events_calendar_item_one
    event.field_civil_worker = "John Doe"
    assert event.save
    
    assert event.has_dynamic_attribute?('field_civil_worker')
    assert_equal "John Doe", event.reload.field_civil_worker
    
    assert event.update_attributes(:field_civil_worker => 'Jane Doe')
    assert_equal "Jane Doe", event.field_civil_worker
  end
  
  def test_should_set_start_and_end_time_based_on_date
    event = create_calendar_item(:date => Date.civil(2011, 1, 1), :start_time => Time.parse('16:00'), :end_time => Time.parse('18:00'))
    assert_equal Time.local(2011, 1, 1, 16), event.start_time
    assert_equal Time.local(2011, 1, 1, 18), event.end_time
  end

  def test_should_set_end_time_on_next_day_when_end_time_smaller_then_start_time
    event = create_calendar_item(:date => Date.civil(2011, 1, 1), :start_time => Time.parse('16:00'), :end_time => Time.parse('11:00'))
    assert_equal Time.local(2011, 1, 1, 16), event.start_time
    assert_equal Time.local(2011, 1, 2, 11), event.end_time
  end

protected

  def create_calendar_item(options = {})
    now = Time.now
    CalendarItem.create({:parent => @events_calendar.node, :repeating => false, :title => "New event", :start_time => now, :end_time => now + 1.hour }.merge(options))
  end

end
