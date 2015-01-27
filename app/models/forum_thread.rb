# This model is used to represent a forum thread that can contain multiple forum
# posts, which are represented using ForumPost objects. Offers functionality
# to open and close a ForumThread.
#
# *Specification*
#
# Attributes
#
# * +user+ - The thread starter.
# * +forum_topic+ - The containing forum topic.
# * +title+ - The title of the forum thread.
# * +closed+ - True if the forum thread is closed, else false.
#
# Preconditions
#
# * Requires the presence of +user+.
# * Requires the presence of +forum_topic+.
# * Requires the presence of +title+.
#
class ForumThread < ActiveRecord::Base
  # Prevents the +closed+ attribute from being assigned in mass assignments.
  attr_protected :closed

  # A +ForumThread+ belongs to a +ForumTopic+.
  belongs_to :forum_topic

  # A +ForumThread+ belongs to a +User+ (i.e. the thread starter).
  belongs_to :user

  # A +ForumThread+ can have many +ForumPost+ children.
  has_many :forum_posts, order: 'created_at ASC', dependent: :destroy do
    # The date at which the last post ForumPost in the ForumThread was added (as identified by +created_at+).
    def last_posting_date
      self.maximum(:created_at)
    end
  end

  # See the preconditions overview for an explanation of these validations.
  validates :title,       presence: true, length: { maximum: 255 }
  validates :forum_topic, presence: true
  validates :user,        presence: true
  validates_numericality_of :forum_topic_id, :user_id

  def self.parent_type
    ForumTopic
  end

  # Returns true if this +ForumThread+ is started by the given +User+, else false.
  def is_owned_by_user?(user)
    self.user == user
  end

  # Returns the date at which this +ForumThread+ was last updated, which is the
  # creation date of the last added +ForumPost+.
  def last_update_date
    self.forum_posts.last_posting_date
  end

  # Closes this +ForumThread+ (i.e. it will no longer accept any new +ForumPost+ children).
  # Returns true if this ForumThread was successfully closed, otherwise false.
  def close
    return false if self.closed?
    self.update_attribute(:closed, true)
    true
  end

  # Opens this +ForumThread+ (i.e. it will accept new +ForumPost+ children again).
  # Returns true if this ForumThread was successfully re-opened, otherwise false.
  def open
    return false unless self.closed?
    self.update_attribute(:closed, false)
    true
  end

  # Returns the start post of this +ForumThread+, i.e. the first +ForumPost+ of this ForumThread.
  def start_post
    self.forum_posts.first(order: 'created_at ASC')
  end

  # Returns the replies to this +ForumThread+, i.e. all +ForumPost+ children of this ForumThread, except the first one.
  def replies
    @replies ||= self.forum_posts[1..-1]
  end

  # Returns the number of replies to this ForumThread
  # (which is all posts minus the starting post).
  def number_of_replies
    self.forum_posts.count - 1
  end
end
