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
# * +subscription_enabled+ - If this event is to be subscribed for.
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

  needs_editor_approval

  # Adds support for optional attributes
  has_dynamic_attributes

  attr_accessor :date

  # See the preconditions overview for an explanation of these validations.
  validates :title,    presence: true, length: { maximum: 255 }
  validates :calendar, presence: true

  before_validation :set_start_and_end_time, if: :start_time

  has_parent :calendar

  has_many :event_registrations, dependent: :destroy
  has_many :users,               through: :event_registrations

  scope :with_ancestry, lambda { |ancestry| includes(:node).where('nodes.ancestry' => ancestry).order('start_time DESC') } do
    include DevcmsCore::CalendarItemsAssociationExtensions
  end

  # Returns a URL alias for a given +node+.
  def path_for_url_alias(node)
    "#{start_time.year}/#{start_time.month}/#{start_time.day}/#{title}"
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.meeting_info')
  end

  def self.send_registration_notifications
    all(conditions: ['start_time <= ? AND subscription_enabled = ?', Time.now + 1.day, true]).each do |event|
      event.update_attribute :subscription_enabled, false
      EventMailer.event_registrations(event).deliver if event.event_registrations.any?
    end
  end

  protected

  def target_date
    date.present? ? date : start_time
  end

  def set_start_and_end_time
    self.end_time = if end_time.nil? || end_time == start_time
                      start_time.change(year: target_date.year, month: target_date.month, day: target_date.day) + 30.minutes
                    elsif end_time < start_time
                      end_time.change(  year: target_date.year, month: target_date.month, day: target_date.day) + 1.day
                    else
                      end_time.change(  year: target_date.year, month: target_date.month, day: target_date.day)
                    end
    self.start_time = start_time.change(year: target_date.year, month: target_date.month, day: target_date.day)
  end
end
