require File.expand_path('../../test_helper.rb', __FILE__)

class CalendarTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @events_calendar = calendars(:events_calendar)
  end

  def test_should_create_calendar
    assert_difference 'Calendar.count' do
      create_calendar
    end
  end

  def test_should_require_title
    assert_no_difference 'Calendar.count' do
      calendar = create_calendar(:title => nil)
      assert calendar.errors[:title].any?
    end

    assert_no_difference 'Calendar.count' do
      calendar = create_calendar(:title => '  ')
      assert calendar.errors[:title].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'Calendar.count', 2 do
      2.times do
        calendar = create_calendar(:title => 'Non-unique title')
        assert !calendar.errors[:title].any?
      end
    end
  end

  def test_should_update_calendar
    assert_no_difference 'Calendar.count' do
      @events_calendar.title = 'New title'
      @events_calendar.description = 'New description'
      assert @events_calendar.save
    end
  end

  def test_should_destroy_calendar
    assert_difference 'Calendar.count', -1 do
      @events_calendar.destroy
    end
  end

  def test_find_years_with_calendar_items
    years = @events_calendar.calendar_items.map { |calendar_item| calendar_item.start_time.year }.uniq

    assert @events_calendar.find_years_with_items.set_equals?(years)
  end

  def test_find_months_with_calendar_items_for_year
    year_month_pairs = @events_calendar.calendar_items.map do |calendar_item|
      [ calendar_item.start_time.year, calendar_item.start_time.month ]
    end.uniq

    year_month_pairs.each do |year_month_pair|
      year = year_month_pair.first
      assert year_month_pairs.select { |year_month_pair| year_month_pair.first == year }.map(&:last).flatten.uniq.set_equals?(@events_calendar.find_months_with_items_for_year(year))
    end
  end

  def test_find_all_calendar_items_for_month
    calendar_items = @events_calendar.calendar_items

    year_month_pairs = calendar_items.map do |calendar_item|
      [ calendar_item.start_time.year, calendar_item.start_time.month ]
    end.uniq

    year_month_pairs.each do |year_month_pair|
      year  = year_month_pair.first
      month = year_month_pair.last
      found_calendar_items = @events_calendar.find_all_items_for_month(year, month)

      calendar_items.each do |calendar_item|
        if calendar_item.start_time.year == year && calendar_item.start_time.month == month
          assert found_calendar_items.include?(calendar_item)
        else
          assert !found_calendar_items.include?(calendar_item)
        end
      end
    end
  end

  def test_should_return_all_future_and_current_events
    time = Time.zone.now

    @events_calendar.calendar_items.current_and_future.each do |event|
      assert event.start_time > time || event.end_time > time
    end

    time = Time.zone.now - 1.year

    @events_calendar.calendar_items.current_and_future(time).each do |event|
      assert event.start_time > time || event.end_time > time
    end

    ae = create_calendar_item({ :calendar => @events_calendar, :title => 'Active event', :start_time => (DateTime.now - 1.hour).to_s(:db),  :end_time => (DateTime.now + 1.hour).to_s(:db), :publication_start_date => 1.day.ago })
    pe = create_calendar_item({ :calendar => @events_calendar, :title =>   'Past event', :start_time => (DateTime.now - 2.hours).to_s(:db), :end_time => (DateTime.now - 1.hour).to_s(:db), :publication_start_date => 1.day.ago })
    assert  @events_calendar.calendar_items.current_and_future.include?(ae)
    assert !@events_calendar.calendar_items.current_and_future.include?(pe)
  end

  def test_last_updated_at_should_return_updated_at_when_no_accessible_calendar_items_are_found
    c = create_calendar
    assert_equal c.node.updated_at.to_i, c.last_updated_at.to_i
    ci = create_calendar_item :calendar => c, :publication_start_date => 1.day.ago
    ci.node.update_attribute(:hidden, true)
    assert_equal c.node.updated_at.to_i, c.last_updated_at.to_i
  end

protected

  def create_calendar(options = {})
    Calendar.create({ :parent => nodes(:root_section_node), :title => 'New calendar', :description => 'This is a new calendar.', :publication_start_date => 2.days.ago }.merge(options))
  end

  def create_calendar_item(options = {})
    CalendarItem.create({ :parent => options[:calendar] ? options.delete(:calendar).node : @events_calendar.node, :repeating => false, :title => 'New event', :start_time => DateTime.now.to_s(:db), :end_time => (DateTime.now + 1.hour).to_s(:db) }.merge(options))
  end
end
