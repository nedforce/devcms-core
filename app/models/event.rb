# This model is used to represent an event. An event is contained within a
# calendar, which in turn is represented by the +Calendar+ model. There can
# be multiple STI specializations of this model, such as +CalendarItem+. It
# has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the event.
# * +body+ - The body containing more information on the event.
# * +location_description+ - The location of the event.
# * +start_time+ - The start time of the event.
# * +end_time+ - The end time of the event.
# * +type+ - The type of the event.
# * +calendar+ - The calendar with which this event is associated.
#
# Preconditions
#
# * Requires the presence of +calendar+.
# * Requires the presence of +title+.
#
# Child/parent type constraints
#
#  * An +Event+ can only be inserted into +Calendar+ nodes.
#
class Event < ActiveRecord::Base
  
  acts_as_content_node
  
  # Adds support for optional attributes
  has_dynamic_attributes

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title, :calendar
  validates_length_of   :title, :in => 2..255, :allow_blank => true
  
  before_validation :set_start_and_end_time, :if => :start_time

  named_scope :in_calendar, lambda{ { :include => :node, :conditions => ["nodes.ancestry IN (?)", Calendar.all.collect {|c| "#{c.node.child_ancestry}" }], :extend => CalendarItemsAssociationExtensions } }
  
  composed_of :date, :class_name => 'Date', :mapping => [ :to_date ], :allow_nil => true
  
  def calendar
    parent = (self.node || self).parent
    parent.content if parent
  end
  
  # Returns a URL alias for a given +node+.
  def path_for_url_alias(node)
    "#{self.start_time.year}/#{self.start_time.month}/#{self.start_time.day}/#{self.title}"
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.meeting_info')
  end

  def set_start_and_end_time
    date = self.date || self.start_time
    self.end_time = if self.end_time.nil? || self.end_time == self.start_time
                      self.start_time.change(:year => date.year, :month => date.month, :day => date.day) + 30.minutes
                    elsif self.end_time < self.start_time
                      self.end_time.change(  :year => date.year, :month => date.month, :day => date.day) + 1.day
                    else
                      self.end_time.change(  :year => date.year, :month => date.month, :day => date.day)
                    end
    self.start_time = self.start_time.change(:year => date.year, :month => date.month, :day => date.day)
  end
end
