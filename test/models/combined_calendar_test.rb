require File.expand_path('../../test_helper.rb', __FILE__)

class CombinedCalendarTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @combined_calendar = combined_calendars(:combined_calendar)
  end

  test 'should create combined calendar' do
    assert_difference 'CombinedCalendar.count' do
      create_combined_calendar
    end
  end

  test 'should require title' do
    assert_no_difference 'CombinedCalendar.count' do
      combined_calendar = create_combined_calendar(title: nil)
      assert combined_calendar.errors[:title].any?
    end

    assert_no_difference 'CombinedCalendar.count' do
      combined_calendar = create_combined_calendar(title: '  ')
      assert combined_calendar.errors[:title].any?
    end
  end

  test 'should not require unique title' do
    assert_difference 'CombinedCalendar.count', 2 do
      2.times do
        combined_calendar = create_combined_calendar(title: 'Non-unique title')
        refute combined_calendar.errors[:title].any?
      end
    end
  end

  test 'should update combined calendar' do
    assert_no_difference 'CombinedCalendar.count' do
      @combined_calendar.title = 'New title'
      @combined_calendar.description = 'New description'
      assert @combined_calendar.save
    end
  end

  test 'should contain all existing calendar items' do
    assert_equal Event.accessible.count, @combined_calendar.calendar_items.count
  end

  test 'should destroy combined calendar' do
    assert_difference 'CombinedCalendar.count', -1 do
      @combined_calendar.destroy
    end
  end

  test 'should not destroy any calendar items on destroy' do
    assert_no_difference 'CalendarItem.count' do
      @combined_calendar.destroy
    end
  end

  test 'should return updated_at for last_updated_at when no accessible calendar items are found' do
    CalendarItem.delete_all
    c = create_combined_calendar
    assert_equal c.updated_at, c.last_updated_at

    ci = create_calendar_item calendars(:events_calendar)
    ci.node.update_attribute(:hidden, true)
    assert_equal c.updated_at, c.last_updated_at
  end

  test 'should exclude sites' do
    own_site = @combined_calendar.node.containing_site
    subsite = own_site.descendants.with_content_type('Site').first

    subsite_calendar = create_calendar parent: subsite
    subsite_calendar_item = create_calendar_item subsite_calendar

    refute @combined_calendar.calendar_items.include?(subsite_calendar_item)

    @combined_calendar.sites << subsite
    @combined_calendar.instance_variable_set :@calendar_items_scope, nil
    assert @combined_calendar.calendar_items.include?(subsite_calendar_item)
  end

  protected

  def create_combined_calendar(options = {})
    CombinedCalendar.create({
      parent: nodes(:root_section_node),
      title: 'New combined calendar',
      description: 'This is a new combined calendar.'
    }.merge(options))
  end

  def create_calendar_item(calendar, options = {})
    CalendarItem.create({
      parent: calendar.node,
      repeating: false,
      title: 'New event',
      start_time: DateTime.now.to_s(:db),
      end_time: (DateTime.now + 1.hour).to_s(:db)
    }.merge(options))
  end

  def create_calendar(options = {})
    Calendar.create({
      parent: nodes(:root_section_node),
      title: 'New calendar',
      description: 'This is a new calendar.',
      publication_start_date: 2.days.ago
    }.merge(options))
  end
end
