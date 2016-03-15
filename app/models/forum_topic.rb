# This model is used to represent a forum topic that can contain multiple forum
# threads, which are represented using +ForumThread+ objects. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +forum+ - The containing forum.
# * +title+ - The title of the forum topic.
# * +description+ - The description of the forum topic.
#
# Preconditions
#
# * Requires the presence of +forum+.
# * Requires the presence of +title+.
# * Requires the presence of +description+.
# * Requires the uniqueness of +title+.
#
# Child/parent type constraints
#
#  * A +ForumTopic+ only accepts +ForumThread+ children.
#
class ForumTopic < ActiveRecord::Base
  # Adds content node functionality to forum topics.
  acts_as_content_node({
    allowed_roles_for_create:  %w( admin ),
    allowed_roles_for_destroy: %w( admin ),
    copyable:                  false
  })

  # A +ForumTopic+ can have many +ForumThread+ children.
  has_many :forum_threads, dependent: :destroy

  # See the preconditions overview for an explanation of these validations.
  validates :title,       presence: true, length: { maximum: 255 }, uniqueness: true
  validates :description, presence: true

  # Returns the child ForumThread objects, ordered by their +last_update_date+ values.
  def forum_threads_by_last_update_date
    forum_threads.select('forum_threads.id, forum_threads.title, forum_threads.user_id, forum_threads.closed, MAX(forum_posts.created_at) AS last_update_date')
      .joins(:forum_posts)
      .group('forum_threads.id, forum_threads.title, forum_threads.user_id')
      .order('MAX(forum_posts.created_at) DESC')
  end

  # Returns the date at which this ForumTopic was last updated.
  # If this ForumTopic contains no ForumThread objects, then the creation date is returned.
  # Otherwise, the maximum last update date of all its child ForumThread objects is returned.
  def last_update_date
    if self.forum_threads.empty?
      self.created_at
    else
      self.forum_threads.joins(:forum_posts).maximum('forum_posts.created_at')
    end
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
