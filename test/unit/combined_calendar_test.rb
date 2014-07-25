require File.expand_path('../../test_helper.rb', __FILE__)

class CombinedCalendarTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
    
  def setup
    @combined_calendar = combined_calendars(:combined_calendar)
  end
  
  def test_should_create_combined_calendar
    assert_difference 'CombinedCalendar.count' do
      create_combined_calendar
    end
  end
  
  def test_should_require_title
    assert_no_difference 'CombinedCalendar.count' do
      combined_calendar = create_combined_calendar(:title => nil)
      assert combined_calendar.errors[:title].any?
    end
    
    assert_no_difference 'CombinedCalendar.count' do
      combined_calendar = create_combined_calendar(:title => "  ")
      assert combined_calendar.errors[:title].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'CombinedCalendar.count', 2 do
      2.times do
        combined_calendar = create_combined_calendar(:title => 'Non-unique title')
        assert !combined_calendar.errors[:title].any?
      end
    end
  end
  
  def test_should_update_combined_calendar
    assert_no_difference 'CombinedCalendar.count' do
      @combined_calendar.title = 'New title'
      @combined_calendar.description = 'New description'
      assert @combined_calendar.save
    end
  end
  
  def test_combined_calendar_should_contain_all_existing_calendar_items
    assert_equal Event.accessible.count, @combined_calendar.calendar_items.count
  end
  
  def test_should_destroy_combined_calendar
    assert_difference "CombinedCalendar.count", -1 do
      @combined_calendar.destroy
    end
  end
  
  def test_destruction_of_combined_calendar_should_not_destroy_any_calendar_items
    assert_no_difference "CalendarItem.count" do
      @combined_calendar.destroy
    end
  end

  def test_last_updated_at_should_return_updated_at_when_no_accessible_calendar_items_are_found
    CalendarItem.delete_all
    c = create_combined_calendar
    assert_equal c.updated_at, c.last_updated_at
    ci = create_calendar_item calendars(:events_calendar)
    ci.node.update_attribute(:hidden, true)
    assert_equal c.updated_at, c.last_updated_at
  end
  
  def test_should_exclude_sites
    own_site = @combined_calendar.node.containing_site
    subsite = own_site.descendants.with_content_type('Site').first
    
    subsite_calendar = create_calendar :parent => subsite
    subsite_calendar_item = create_calendar_item subsite_calendar
    
    assert !@combined_calendar.calendar_items.include?(subsite_calendar_item)

    @combined_calendar.sites << subsite    
    @combined_calendar.instance_variable_set :@calendar_items_scope, nil
    assert @combined_calendar.calendar_items.include?(subsite_calendar_item)
  end

protected

  def create_combined_calendar(options = {})
    CombinedCalendar.create({ :parent => nodes(:root_section_node), :title => 'New combined calendar', :description => 'This is a new combined calendar.' }.merge(options))
  end

  def create_calendar_item(calendar, options = {})
    CalendarItem.create({ :parent => calendar.node, :repeating => false, :title => 'New event', :start_time => DateTime.now.to_s(:db), :end_time => (DateTime.now + 1.hour).to_s(:db) }.merge(options))
  end

  def create_calendar(options = {})
    Calendar.create({ :parent => nodes(:root_section_node), :title => 'New calendar', :description => 'This is a new calendar.', :publication_start_date => 2.days.ago }.merge(options))
  end
end
