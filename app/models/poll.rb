# A +Poll+ is a content node that houses poll questions. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# A +Poll+ serves as an archive for +PollQuestion+ objects, of which only
# 1 can be active.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the poll.
# * +requires_login+ - True if this poll requires users to be logged in to vote
#
# Preconditions
#
# * Requires the presence of +title+.
#
# Child/parent type constraints
#
#  * A Poll only accepts PollQuestion nodes.
#  * A Poll can be inserted into nodes of any accepting type.
#
class Poll < ActiveRecord::Base
  # Adds content node functionality to polls.
  acts_as_content_node(
    allowed_child_content_types:       %w( PollQuestion ),
    allowed_roles_for_create:          %w( admin final_editor ),
    allowed_roles_for_destroy:         %w( admin final_editor ),
    available_content_representations: ['content_box'],
    children_can_be_sorted:            false
  )

  has_children :poll_questions

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }

  # Returns the active +PollQuestion+ of this +Poll+ if one exists,
  # returns +nil+ otherwise.
  def active_question
    poll_questions.accessible.where(active: true).first
  end

  # Returns the image file name to be used for icons on the front-end website.
  def icon_filename
    'poll_question.png'
  end

  def last_updated_at
    [updated_at, active_question.try(:updated_at)].compact.max
  end
end
