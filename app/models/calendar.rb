# This model is used to represent a calendar that can contain multiple events
# (calendar items), which are represented using +CalendarItem+ objects. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the calendar.
# * +description+ - The description of the calendar.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class Calendar < ActiveRecord::Base
  # Adds content node functionality to calendars.
  acts_as_content_node({
    allowed_child_content_types:       %w( CalendarItem Meeting ),
    allowed_roles_for_update:          %w( admin final_editor ),
    allowed_roles_for_create:          %w( admin final_editor ),
    allowed_roles_for_destroy:         %w( admin final_editor ),
    available_content_representations: ['content_box'],
    has_own_feed:                      true,
    children_can_be_sorted:            false,
    tree_loader_name:                  'calendars'
  })

  # Extend this class with methods to find items based on their start time.
  acts_as_archive date_field_model_name: :start_time, date_field_database_name: 'start_time', items_name: :calendar_items, sql_options: nil

  # A +Calendar+ can have many +Event+ children.
  has_children :calendar_items, class_name: 'Event', order: 'start_time DESC', extend: DevcmsCore::CalendarItemsAssociationExtensions

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }


  # Returns the last update date
  def last_updated_at
    [ self.calendar_items.accessible.maximum('nodes.created_at'), self.updated_at ].compact.max
  end
  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
