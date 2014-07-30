# This model is used to represent an agenda item of a particular meeting,
# which in turn is represented by the Meeting model. A Meeting optionally belongs
# to an associated AgendaItemCategory. It has specified +acts_as_content_node+
# from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +meeting+ - The meeting this agenda item belongs to.
# * +agenda_item_category+ - The category that this agenda item belongs to (optional).
# * +description+ - A short description of this agenda item.
# * +body+ - The body of this agenda item.
# * +duration+ - The duration of this agenda item.
# * +chairman+ - The chairman of this agenda item.
# * +notary+ - The notary of this agenda item.
# * +staff_member+ - The staff member of this agenda item.
# * +speaking_rights+ - The speaking rights for this agenda item (valid options are the keys of +SPEAKING_RIGHT_OPTIONS+, or +nil+).
#
# Preconditions
#
# * Requires +meeting_id+ to be present and point to a Meeting instance.
# * Requires +agenda_item_category_id+ to point to a AgendaItemCategory instance, if present.
# * Requires the presence of +description+.
# * Requires +speaking_rights+ to be a key of +SPEAKING_RIGHT_OPTIONS+, or +nil+. 
#
# Child/parent type constraints
#
# * An AgendaItem only accepts Attachment children.
# * An AgendaItem can only be inserted into Meeting nodes.
#
class AgendaItem < ActiveRecord::Base

  # The various options for +speakings_rights+.
  SPEAKING_RIGHT_OPTIONS = {
    0 => 'no',
    1 => 'yes'
  }

  # Adds content node functionality to agenda items.
  acts_as_content_node({
    :allowed_child_content_types => %w( Attachment AttachmentTheme ),
    :show_in_menu                => false,
    :copyable                    => false
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # An AgendaItem belongs to a Meeting.
  has_parent :calendar_item, :class_name => 'Event'

  # An AgendaItem optionally belongs to an AgendaItemCategory.
  belongs_to :agenda_item_category

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :calendar_item, :description
  validates_associated      :agenda_item_category,    :if => :has_agenda_item_category?
  validates_numericality_of :agenda_item_category_id,                             :allow_nil => true
  validates_numericality_of :speaking_rights,                                     :allow_nil => true
  validates_inclusion_of    :speaking_rights, :in => SPEAKING_RIGHT_OPTIONS.keys, :allow_nil => true
  validate                  :ensure_associated_calendar_item_is_a_meeting

  # Returns the +name+ of the associated AgendaItemCategory, or +nil+ if no AgendaItemCategory is associated.
  def agenda_item_category_name
    self.agenda_item_category.name if self.agenda_item_category
  end

  # Sets the associated AgendaItemCategory using the given +name+.
  # If there is no AgendaItemCategory with the given +name+, a new one is created.
  def agenda_item_category_name=(name)
    self.agenda_item_category = AgendaItemCategory.find_or_new_by_name(name.to_s) if name.present?
  end

  # Aliases +description+ as +title+.
  def title
    self.description
  end

  def title_changed?
    self.description_changed?
  end

protected

  # Returns +true+ if an AgendaItemCategory is associated (i.e., a foreign key is present), else +false+.
  def has_agenda_item_category?
    !self.agenda_item_category.nil?
  end

  # Ensures the associated CalendarItem is a Meeting.
  def ensure_associated_calendar_item_is_a_meeting
    errors.add(:calendar_item, :calendar_item_must_be_a_meeting) if self.calendar_item && !self.calendar_item.is_a?(Meeting)
  end
end
