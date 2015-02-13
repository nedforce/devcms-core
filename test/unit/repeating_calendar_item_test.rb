require File.expand_path('../../test_helper.rb', __FILE__)

class RepeatingCalendarItemTest < ActiveSupport::TestCase
#   self.use_transactional_fixtures = true
# 
#   def setup
#     @events_calendar = calendars(:events_calendar)
#     @arthur = users(:arthur)
#   end
# 
#   def test_has_repetitions?
#     ci = create_repeating_calendar_item :repeating => true
#     assert ci.has_repetitions?
#   end
# 
#   def test_repeating?
#     ci = create_repeating_calendar_item :repeating => true
#     assert ci.repeating?
# 
#     ci = create_calendar_item
#     assert !ci.repeating?
#   end
# 
#   def test_should_destroy_non_repeating_calendar_item
#     now = Time.now
# 
#     ci = create_calendar_item
# 
#     assert_difference('CalendarItem.count', -1) do
#       CalendarItem.destroy_calendar_item(ci)
#     end
#   end
# 
#   def test_should_destroy_repeating_calendar_item_and_its_repetitions
#     now = Time.now
# 
#     ci = create_repeating_calendar_item({
#       :start_time => now,
#       :end_time => now + 1.hours,
#       :repeating => true,
#       :repeat_interval_multiplier => 1,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
#       :repeat_end => (now + 1.week).to_date
#     })
# 
#     created_items_count = count_number_of_created_calendar_items(ci.start_time.to_date, ci.repeat_end, 1.days)
# 
#     assert_difference('CalendarItem.count', -created_items_count) do
#       CalendarItem.destroy_calendar_item(ci)
#     end
#   end
# 
#   def test_repeat_interval_multipliers
#     repeat_interval_multipliers = CalendarItem.repeat_interval_multipliers
#     assert_equal CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.to_a.size, repeat_interval_multipliers.size
#     assert_equal CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.min, repeat_interval_multipliers.min
#     assert_equal CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.max, repeat_interval_multipliers.max
#     assert_equal repeat_interval_multipliers.sort, repeat_interval_multipliers
#   end
# 
#   def test_repeat_interval_granularities
#     repeat_interval_granularities = CalendarItem.repeat_interval_granularities
#     assert_equal CalendarItem::REPEAT_INTERVAL_GRANULARITIES.size, repeat_interval_granularities.size
# 
#     repeat_interval_granularities.each do |k, v|
#       assert_equal I18n.t(CalendarItem::REPEAT_INTERVAL_GRANULARITIES_REVERSE[v], :scope => :calendars), k
#     end
#   end
# 
#   def test_should_assign_repeating_to_virtual_attribute
#     [ [ true, true ], [ false, false ], [ nil, nil ], [ ' ', nil ], [ '0', false ], [ '1', true ]].each do |k, v|
#       ci = create_repeating_calendar_item :repeating => k
#       assert_equal v, ci.repeating, " #{v.inspect} expected but was #{ci.repeating.inspect} for #{k.inspect}"
#     end
#   end
# 
#   def test_should_not_require_valid_repeating_on_update
#     [ 'asdsad', -1, nil ].each do |repeating|
#       ci = create_repeating_calendar_item
#       ci.repeating = repeating
#       assert ci.save(:user => @arthur)
#       assert ci.valid?
#       assert !ci.errors[:repeating].any?
#     end
#   end
# 
#   def test_should_assign_repeat_interval_granularity_to_virtual_attribute
#     repeat_interval_granularity = CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.first
#     ci = create_repeating_calendar_item :repeat_interval_granularity => repeat_interval_granularity
#     assert_equal repeat_interval_granularity, ci.repeat_interval_granularity
#   end
# 
#   def test_should_require_valid_repeat_interval_granularity_on_create_if_repeating_is_true
#     [ nil, CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.min - 1, 'foo', CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.max + 1 ].each do |repeat_interval_granularity|
#       ci = create_repeating_calendar_item :repeat_interval_granularity => repeat_interval_granularity
#       assert !ci.valid?
#       assert ci.errors[:repeat_interval_granularity].any?
#     end
#   end
# 
#   def test_should_not_require_valid_repeat_interval_granularity_on_update
#     [ nil, CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.min - 1, 'foo', CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.max + 1 ].each do |repeat_interval_granularity|
#       ci = create_repeating_calendar_item
#       ci.repeating = true
#       ci.repeat_interval_granularity = repeat_interval_granularity
#       assert ci.save(:user => @arthur)
#       assert ci.valid?
#       assert !ci.errors[:repeat_interval_granularity].any?
#     end
#   end
# 
#   def test_should_not_require_valid_repeat_interval_granularity_on_create_if_repeating_is_false
#     [ nil, CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.min - 1, 'foo', CalendarItem::REPEAT_INTERVAL_GRANULARITIES_VALUES.max + 1 ].each do |repeat_interval_granularity|
#       ci = create_repeating_calendar_item :repeating => false, :repeat_interval_granularity => repeat_interval_granularity
#       assert ci.valid?
#       assert !ci.errors[:repeat_interval_granularity].any?
#     end
#   end
# 
#   def test_should_assign_repeat_interval_multiplier_to_virtual_attribute
#     repeat_interval_multiplier = CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.min
#     ci = create_repeating_calendar_item :repeating => true, :repeat_interval_multiplier => repeat_interval_multiplier
#     assert_equal repeat_interval_multiplier, ci.repeat_interval_multiplier
#   end
# 
#   def test_should_require_valid_repeat_interval_multiplier_on_create_if_repeating_is_true
#     [ nil, CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.min - 1, 'foo', CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.max + 1 ].each do |repeat_interval_multiplier|
#       ci = create_repeating_calendar_item :repeating => true, :repeat_interval_multiplier => repeat_interval_multiplier
#       assert !ci.valid?
#       assert ci.errors[:repeat_interval_multiplier].any?
#     end
#   end
# 
#   def test_should_not_require_valid_repeat_interval_multiplier_on_update
#     [ nil, CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.min - 1, 'foo', CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.max + 1 ].each do |repeat_interval_multiplier|
#       ci = create_repeating_calendar_item
#       ci.repeating = true
#       ci.repeat_interval_multiplier = repeat_interval_multiplier
#       assert ci.save(:user => @arthur)
#       assert ci.valid?
#       assert !ci.errors[:repeat_interval_multiplier].any?
#     end
#   end
# 
#   def test_should_not_require_valid_repeat_interval_multiplier_on_create_if_repeating_is_false
#     [ nil, CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.min - 1, 'foo', CalendarItem::REPEAT_INTERVAL_MULTIPLIER_RANGE.max + 1 ].each do |repeat_interval_multiplier|
#       ci = create_repeating_calendar_item :repeating => false, :repeat_interval_multiplier => repeat_interval_multiplier
#       assert ci.valid?
#       assert !ci.errors[:repeat_interval_multiplier].any?
#     end
#   end
# 
#   def test_should_assign_repeat_end_to_virtual_attribute
#     repeat_end = 1.years.from_now.to_date
#     ci = create_repeating_calendar_item :repeating => true, :repeat_end => repeat_end
#     assert_equal Date.parse(repeat_end.to_s), ci.repeat_end
#   end
# 
#   def test_should_require_repeat_end_on_create_if_repeating_is_true
#     ci = create_repeating_calendar_item :repeating => true, :repeat_end => nil
#     assert !ci.valid?
#     assert ci.errors[:repeat_end].any?
#   end
# 
#   def test_should_not_require_repeat_end_on_update
#     ci = create_repeating_calendar_item
#     ci.repeating = true
#     ci.instance_variable_set(:@repeat_end, nil)
#     assert ci.save(:user => @arthur)
#     assert ci.valid?
#     assert !ci.errors[:repeat_end].any?
#   end
# 
#   def test_should_not_require_repeat_end_on_create_if_repeating_is_false
#     ci = create_repeating_calendar_item :repeating => false
#     assert ci.valid?
#     assert !ci.errors[:repeat_end].any?
#   end
# 
#   def test_should_require_repeat_end_to_be_in_the_future_on_create_if_repeating_is_true
#     ci = create_repeating_calendar_item :repeating => true, :repeat_end => 1.day.ago.to_date
#     assert !ci.valid?
#     assert ci.errors[:repeat_end].any?
#   end
# 
#   def test_should_not_require_repeat_end_to_be_in_the_future_on_update
#     ci = create_repeating_calendar_item
#     ci.repeating = true
#     ci.instance_variable_set(:@repeat_end, 1.day.ago.to_date)
#     assert ci.save(:user => @arthur)
#     assert ci.valid?
#     assert !ci.errors[:repeat_end].any?
#   end
# 
#   def test_should_not_require_repeat_end_to_be_in_the_future_on_create_if_repeating_is_false
#     ci = create_repeating_calendar_item :repeating => false, :repeat_end => 1.day.ago.to_date
#     assert ci.valid?
#     assert !ci.errors[:repeat_end].any?
#   end
# 
#   def test_should_assign_repeat_identifier_after_create_if_repeating_is_true
#     ci = create_repeating_calendar_item :repeating => true
#     assert_not_nil ci.repeat_identifier
#   end
# 
#   def test_should_not_assign_repeat_identifier_after_create_if_repeating_is_false
#     ci = create_repeating_calendar_item :repeating => false
#     assert_nil ci.repeat_identifier
#   end
# 
#   def test_should_not_assign_new_repeat_identifier_on_update
#     ci = create_repeating_calendar_item :repeating => true
#     repeat_identifier = ci.repeat_identifier
#     ci.title = 'New title'
#     ci.save(:user => @arthur)
#     assert_equal repeat_identifier, ci.reload.repeat_identifier
#   end
# 
#   def test_repeat_identifier_must_be_a_protected_attribute
#     ci = create_repeating_calendar_item :repeating => true
#     old_repeat_identifier = ci.repeat_identifier
#     new_repeat_identifier = old_repeat_identifier + 1
#     ci.send(:update_attributes, :repeat_identifier => new_repeat_identifier)
#     assert_equal old_repeat_identifier, ci.reload.repeat_identifier
#   end
# 
#   def test_repeat_identifier_must_be_a_unique_attribute
#     # No better way to test this, as repeat_identifer is a readonly attribute (thus no updating)
#     ci = create_repeating_calendar_item :repeating => true
#     ci2 = create_repeating_calendar_item
#     assert ci.repeat_identifier != ci2.repeat_identifier
#   end
# 
#   def test_should_not_create_extra_calendar_items_for_non_repeating_calendar_item
#     assert_difference('CalendarItem.count', 1) do
#       create_repeating_calendar_item :repeating => false
#     end
#   end
# 
#   def test_should_not_create_extra_calendar_items_after_updating_repeating_calendar_item
#     ci = create_repeating_calendar_item
# 
#     assert_no_difference('CalendarItem.count') do
#       now = Time.now
# 
#       ci.attributes = {
#         :start_time => now,
#         :end_time => now + 1.hours,
#         :repeating => true,
#         :repeat_interval_multiplier => 1,
#         :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
#         :repeat_end => (now + 1.week).to_date
#       }
# 
#       ci.save(:user => @arthur)
#     end
#   end
# 
#   def test_should_not_create_extra_calendar_items_for_repeating_calendar_item_with_invalid_repeat_interval_and_repeat_end_combination
#     assert_difference('CalendarItem.count', 1) do
#       now = Time.now
# 
#       ci = create_repeating_calendar_item({
#         :start_time => now,
#         :end_time => now + 1.hours,
#         :repeating => true,
#         :repeat_interval_multiplier => 1,
#         :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:weeks],
#         :repeat_end => (now + 1.day).to_date
#       })
#     end
#   end
# 
#   def test_should_create_extra_calendar_items_for_repeating_calendar_item
#     start_time = Time.now
#     end_time = start_time + 1.hour
#     common_attributes = { :start_time => start_time, :end_time => end_time }
# 
#     attribute_hashes = [ {
#       :repeat_interval_multiplier => 1,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
#       :repeat_end => (start_time + 1.week).to_date,
#       :title => 'Foo1',
#       :location_description => 'Foo1',
#       :body => 'Foo1'
#     }, {
#       :repeat_interval_multiplier => 3,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
#       :repeat_end => (start_time + 2.weeks).to_date,
#       :title => 'Foo2',
#       :location_description => 'Foo2',
#       :body => 'Foo2'
#     }, {
#       :repeat_interval_multiplier => 1,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:weeks],
#       :repeat_end => (start_time + 2.month).to_date,
#       :title => 'Foo3',
#       :location_description => 'Foo3',
#       :body => 'Foo3'
#     }, {
#       :repeat_interval_multiplier => 3,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:weeks],
#       :repeat_end => (start_time + 7.months).to_date,
#       :title => 'Foo4',
#       :location_description => 'Foo4',
#       :body => 'Foo4'
#     }, {
#       :repeat_interval_multiplier => 2,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:months],
#       :repeat_end => (start_time + 1.year).to_date,
#       :title => 'Foo5',
#       :location_description => 'Foo5',
#       :body => 'Foo5'
#     }, {
#       :repeat_interval_multiplier => 5,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:months],
#       :repeat_end => (start_time + 3.years).to_date,
#       :title => 'Foo6',
#       :location_description => 'Foo6',
#       :body => 'Foo6'
#     } ]
# 
#     attribute_hashes.each do |attribute_hash|
#       start_date = start_time.to_date
#       end_date = attribute_hash[:repeat_end]
#       span = attribute_hash[:repeat_interval_multiplier].send(CalendarItem::REPEAT_INTERVAL_GRANULARITIES_REVERSE[attribute_hash[:repeat_interval_granularity]])
#       difference = count_number_of_created_calendar_items(start_date, end_date, span)
# 
#       assert_difference('CalendarItem.count', difference) do
#         ci = create_repeating_calendar_item(attribute_hash.merge(common_attributes))
#         assert ci.valid?
# 
#         ## Retrieve all calendar ites with ci's repeat_identifier, these are the original calendar item (ci) and the copies
#         created_calendar_items = CalendarItem.all(
#           :order => 'start_time DESC',
#           :conditions => { :repeat_identifier => ci.repeat_identifier }
#         )
# 
#         assert created_calendar_items.include?(ci)
#         assert_equal difference, created_calendar_items.size
# 
#         # Check if all calendar items have the same values for the given attributes
#         [ :title, :location_description, :body ].each do |attribute|
#           assert_equal 1, created_calendar_items.map(&attribute).uniq.size, "Expected all attributes to be equal for #{created_calendar_items.pretty_inspect}"
#         end
# 
#         ## Check if the calendar items have 'span' intervals
#         i = 0
# 
#         while i < (created_calendar_items.size - 1)
#           assert_equal created_calendar_items[i].start_time.to_date, (created_calendar_items[i + 1].start_time.to_date + span)
#           i = i + 1
#         end
#       end
#     end
#   end
#
# protected
#
#   def create_calendar_item(options = {})
#     now = Time.now
#     CalendarItem.create({ :parent => @events_calendar.node, :repeating => false, :title => 'New event', :start_time => now, :end_time => now + 1.hour }.merge(options))
#   end
#
#   def create_repeating_calendar_item(options = {})
#     create_calendar_item({
#       :repeating => true,
#       :repeat_interval_multiplier => 1,
#       :repeat_interval_granularity => CalendarItem::REPEAT_INTERVAL_GRANULARITIES[:days],
#       :repeat_end => 1.month.from_now.to_date
#     }.merge(options))
#   end
#
#   def count_number_of_created_calendar_items(start_date, end_date, span)
#     amount = 0
#     next_date = start_date
#
#     while (next_date <= end_date)
#       amount += 1
#       next_date += span
#     end
#
#     amount
#   end
end
