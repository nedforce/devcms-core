# This model is a STI specialization of CalendarItem and is used to represent
# a meeting. A meeting can contain many agenda items, which in turn are represented
# with the AgendaItem content type. A Meeting always belongs to an associated
# MeetingCategory. It has specified +acts_as_content_node+ from
# Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +meeting_category+ - The category that this meeting belongs to.
# * +agenda_items+ - The agenda items belonging to this meeting.
#
# Preconditions
#
# * Requires +meeting_category_id+ to be present and point to a MeetingCategory instance.
#
# Child/parent type constraints
#
#  * A Meeting only accepts AgendaItem children.
#
class Meeting < CalendarItem
  acts_as_content_node({
    allowed_child_content_types: %w( Attachment AttachmentTheme AgendaItem ),
    show_in_menu:                false,
    copyable:                    false,
    controller_name:             'meetings'
  })

  needs_editor_approval

  # The category that this meeting belongs to.
  belongs_to :meeting_category

  # A Meeting can have many agenda items.
  has_children :agenda_items, order: 'nodes.position'

  # See the preconditions overview for an explanation of these validations.
  validates_associated      :meeting_category
  validates_presence_of     :meeting_category
  validates_numericality_of :meeting_category_id, allow_nil: true

  # Returns the +name+ of the associated MeetingCategory, or +nil+ if no MeetingCategory is associated.
  def meeting_category_name
    self.meeting_category.name if self.meeting_category
  end

  # Sets the associated MeetingCategory using the given +name+.
  # If there is no MeetingCategory with the given +name+, a new one is created.
  def meeting_category_name=(name)
    self.meeting_category = MeetingCategory.find_or_new_by_name(name.to_s) if name.present?
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.meeting_info')
  end

protected

  def cloning_hash
    super.merge({ meeting_category: self.meeting_category })
  end
end
