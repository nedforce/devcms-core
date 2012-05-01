require File.expand_path('../../test_helper.rb', __FILE__)

class RepeatingMeetingTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @meetings_calendar = calendars(:meetings_calendar)
    @meeting_category = meeting_categories(:gemeenteraad_meetings)
  end

  def test_should_create_extra_meetings_for_repeating_meeting
    start_time = Time.now
    end_time = start_time + 1.hour
    common_attributes = { :start_time => start_time, :end_time => end_time }

    attribute_hashes = [ {
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:days],
      :repeat_end => (start_time + 1.week).to_date,
      :title => 'Foo1',
      :body => 'Foo1',
      :meeting_category => @meeting_category
    }, {
      :repeat_interval_multiplier => 3,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:days],
      :repeat_end => (start_time + 2.weeks).to_date,
      :title => 'Foo2',
      :body => 'Foo2',
      :meeting_category => @meeting_category
    }, {
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:weeks],
      :repeat_end => (start_time + 2.month).to_date,
      :title => 'Foo3',
      :body => 'Foo4',
      :meeting_category => @meeting_category
    }, {
      :repeat_interval_multiplier => 3,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:weeks],
      :repeat_end => (start_time + 7.months).to_date,
      :title => 'Foo4',
      :body => 'Foo4',
      :meeting_category => @meeting_category
    }, {
      :repeat_interval_multiplier => 2,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:months],
      :repeat_end => (start_time + 1.year).to_date,
      :title => 'Foo5',
      :body => 'Foo5',
      :meeting_category => @meeting_category
    }, {
      :repeat_interval_multiplier => 5,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:months],
      :repeat_end => (start_time + 3.years).to_date,
      :title => 'Foo6',
      :body => 'Foo6',
      :meeting_category => @meeting_category
    } ]

    attribute_hashes.each do |attribute_hash|
      start_date = start_time.to_date
      end_date = attribute_hash[:repeat_end]
      span = attribute_hash[:repeat_interval_multiplier].send(Meeting::REPEAT_INTERVAL_GRANULARITIES_REVERSE[attribute_hash[:repeat_interval_granularity]])
      difference = count_number_of_created_meetings(start_date, end_date, span)

      assert_difference('Meeting.count', difference) do
        m = create_repeating_meeting(attribute_hash.merge(common_attributes))

        ## Retrieve all calendar ites with m's repeat_identifier, these are the original calendar item (m) and the copies
        created_meetings = Meeting.all(
          :order => 'start_time DESC',
          :conditions => { :repeat_identifier => m.repeat_identifier }
        )

        assert created_meetings.include?(m)
        assert_equal difference, created_meetings.size

        # Check if all calendar items have the same values for the given attributes
        [ :title, :location, :meeting_category ].each do |attribute|
          assert_equal created_meetings.map(&attribute).uniq.size, 1
        end

        ## Check if the calendar items have 'span' intervals
        i = 0

        while i < (created_meetings.size - 1)
          assert_equal created_meetings[i].start_time.to_date, (created_meetings[i + 1].start_time.to_date + span)
          i = i + 1
        end
      end
    end
  end

protected

  def create_meeting(options = {})
    now = Time.now

    Meeting.create({:parent => @meetings_calendar.node,
      :meeting_category => @meeting_category,
      :title => "New meeting",
      :start_time => now,
      :end_time => now + 1.hour
    }.merge(options))
  end

  def create_repeating_meeting(options = {})
    create_meeting({
      :repeating => true,
      :repeat_interval_multiplier => 1,
      :repeat_interval_granularity => Meeting::REPEAT_INTERVAL_GRANULARITIES[:weeks],
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
