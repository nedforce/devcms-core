# This model is used to represent a calendar item, which is a specialization of +Event+.
# A calendar item is contained within a calendar, which in turn is represented by the
# +Calendar+ model. There can be multiple STI specializations of this model, such as +Meeting+.
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +calendar+ - The calendar this item belongs to
# * +title+ - The title of the event.
# * +body+ - The description of the event.
# * +location_description+ - The location_description of the event.
# * +start_time+ - The start time of the event.
# * +end_time+ - The end time of the event.
# * +repeat_identifier+ - Calendar item this item is a repetition of
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +start_time+.
# * Requires the presence of +end_time+.
# * Requires the presence of +calendar+.
#
# Child/parent type constraints
#
#  * A +CalendarItem+ only accepts +Attachment+ children.
#  * A +CalendarItem+ can only be inserted into +Calendar+ nodes.
#
class CalendarItem < Event
  # Possible multipliers for repetition interval.
  REPEAT_INTERVAL_MULTIPLIER_RANGE = 1..5

  # Possible granularities (units) for repetition interval.
  REPEAT_INTERVAL_GRANULARITIES = {
    :days   => 0,
    :weeks  => 1,
    :months => 2,
    :years  => 3
  }.freeze

  # Repetition interval granularity values for validation.
  REPEAT_INTERVAL_GRANULARITIES_VALUES  = REPEAT_INTERVAL_GRANULARITIES.values.freeze

  # Reversed hash of possible granularities (units) for repetition interval.
  REPEAT_INTERVAL_GRANULARITIES_REVERSE = REPEAT_INTERVAL_GRANULARITIES.inject({}) do |hash, (key, value)|
    hash[value] = key
    hash
  end.freeze
  
  # Adds content node functionality to event.
   acts_as_content_node({
     :allowed_child_content_types => %w( Attachment AttachmentTheme ),
     :show_in_menu => false,
     :copyable => false,
     :controller_name => 'calendar_items'
   })
   
  needs_editor_approval

  # Create repeating calendar items if necessary.
  after_create :create_repeating_calendar_items

  # Assign an unique repeat_identifier is this is a repeating calendar item.
  before_validation :assign_repeat_identifier_if_repeating, :on => :create

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of  :start_time, :end_time
  validates_inclusion_of :repeating,                   :in => [ true, false ], :allow_blank => true,                    :on => :create
  validates_inclusion_of :repeat_interval_granularity, :in => REPEAT_INTERVAL_GRANULARITIES_VALUES, :if => :repeating?, :on => :create
  validates_inclusion_of :repeat_interval_multiplier,  :in => REPEAT_INTERVAL_MULTIPLIER_RANGE,     :if => :repeating?, :on => :create
  validates_presence_of  :repeat_end,                                                               :if => :repeating?, :on => :create
  validate               :repeat_end_should_be_in_the_future, :on => :create
  validate               :end_time_should_be_after_start_time

  attr_protected :repeat_identifier

  # Virtual attributes for creating repeating calendar items.
  attr_reader :repeat_end, :repeating, :repeat_interval_granularity, :repeat_interval_multiplier

  # Determine if this calendar item has repetitions.
  def has_repetitions?
    !self.repeat_identifier.nil?
  end

  # Do we need to create repetitions?
  def repeating?
    !self.repeating.nil? && self.repeating
  end

  # Possible multipliers for repetition interval as array
  def self.repeat_interval_multipliers
    @repeat_interval_multipliers ||= REPEAT_INTERVAL_MULTIPLIER_RANGE.to_a
  end
  
  # Translate interval granularities
  def self.repeat_interval_granularities
    @repeat_interval_granularities ||= CalendarItem::REPEAT_INTERVAL_GRANULARITIES.to_a.map do | k, v |
      [ I18n.t(k, :scope => :calendars), v ]
    end.sort { | a, b | a.last <=> b.last }
  end

  # Destroy calendar item and all of its repetitions
  def self.destroy_calendar_item(calendar_item, paranoid_delete = false)
    if calendar_item.has_repetitions?
      CalendarItem.all(:conditions => { :repeat_identifier => calendar_item.repeat_identifier }).each do |repetition|
        if paranoid_delete
          repetition.node.paranoid_delete!
        else
          repetition.destroy
        end
      end
    else
      if paranoid_delete
        calendar_item.node.paranoid_delete!
      else
        calendar_item.destroy
      end
    end
  end

  # Repetition of the calendar item will be created until this date
  def repeat_end=(value)
    @repeat_end = Date.parse(value.to_s) if value.present?
  end

  # Flag is repetitions of this calendar item should be created
  def repeating=(value)
    @repeating = (value.present? || value.is_a?(FalseClass)) ? value.to_boolean : nil
  end

  # Set repeat interval granularity (day, week, month)
  def repeat_interval_granularity=(value)
    @repeat_interval_granularity = value.to_i if value.is_a?(Integer) || value =~ %r(\A\d+\Z)
  end

  # Set repeat interval multiplier (1, 2, 3, 4, 5)
  def repeat_interval_multiplier=(value)
    @repeat_interval_multiplier = value.to_i if value.is_a?(Integer) || value =~ %r(\A\d+\Z)
  end

  # Returns the body and location_description as the tokens for indexing.
  def content_tokens
    [ body, location_description ].compact.join(' ')
  end

  def registration_for_user(user)
    event_registrations.first(:conditions => {:user_id => user.id})
  end

protected

  # Validate that calendar items ends later than it starts.
  def end_time_should_be_after_start_time
    errors.add(:end_time, :end_time_not_after_start_time) if self.start_time && self.end_time && (self.end_time <= self.start_time)
  end

  # Validate that the end of repetition is in the future.
  def repeat_end_should_be_in_the_future
    errors.add(:repeat_end, :repeat_end_should_be_in_the_future) if self.repeating? && self.repeat_end && self.repeat_end <= Date.today
  end

  # Set the repetition grouping identifier when calendar item is repeated.
  def assign_repeat_identifier_if_repeating
    self.repeat_identifier = (CalendarItem.maximum(:repeat_identifier) || 0) + 1 if self.repeating? && self.repeat_identifier.blank?
  end

  # Create repetitions of calendar item if it is repeating.
  def create_repeating_calendar_items
    # Don't do anything if this item is not repeating.
    return true unless self.repeating?

    # Calculate the time interval between repeating items.
    span = self.repeat_interval_multiplier.send(REPEAT_INTERVAL_GRANULARITIES_REVERSE[self.repeat_interval_granularity])

    # Assign local variables.
    parent          = self.calendar.node
    next_start_time = self.start_time + span
    next_end_time   = self.end_time   + span
    end_date        = self.repeat_end

    # Loop that creates items.
    while (next_start_time.to_date <= end_date)
      # Initialize with cloned parameters and new times.
      calendar_item = self.class.new(cloning_hash.merge({
        :repeating  => false,
        :start_time => next_start_time,
        :end_time   => next_end_time
      }))

      # Assign other attributes.
      calendar_item.repeat_identifier = self.repeat_identifier
      calendar_item.parent            = parent

      # Save calendar item.
      if (self.versioned?)
        calendar_item.save!(:user => self.versions.current.editor)
      else
        calendar_item.save!
      end

      # Increment times with repetition interval.
      next_start_time += span
      next_end_time   += span
    end
    
    true
  end

  # Attributes hash that needs to be included in repeating items.
  def cloning_hash
    {
      :title                => self.title,
      :body                 => self.body,
      :location_description => self.location_description
    }
  end
end
