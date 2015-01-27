# A MeetingCategory is used to group common meetings. Thus, it can contain
# many meetings, each represented with the Meeting content type.
#
# *Specification*
#
# Attributes
#
# * +name+ - The name of the category.
# * +calendar_items+ - The meetings that belong to this category.
#
# Preconditions
#
# * Requires +name+ to be present.
# * Requires the uniqueness of +name+.
#
class MeetingCategory < ActiveRecord::Base
  # The meetings that belong to this category.
  has_many :calendar_items, dependent: :destroy

  # See the preconditions overview for an explanation of these validations.
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true

  # Finds the meeting category with the given name, or initializes a new one with
  # that name (but does *not* save it).
  def self.find_or_new_by_name(name)
    MeetingCategory.find_by_name(name) || MeetingCategory.new(:name => name)
  end
end
