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
  attr_accessor :is_being_destroyed

  # A +ForumThread+ belongs to a +ForumTopic+.
  belongs_to :forum_topic

  # A +ForumThread+ belongs to a +User+ (i.e. the thread starter).
  belongs_to :user

  # A +ForumThread+ can have many +ForumPost+ children.
  has_many :forum_posts, ->{ order(created_at: :asc) }, inverse_of: :forum_thread, dependent: :destroy do
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
    forum_posts.last_posting_date
  end

  # Closes this +ForumThread+ (i.e. it will no longer accept any new +ForumPost+ children).
  # Returns true if this ForumThread was successfully closed, otherwise false.
  def close
    return false if self.closed?
    update_attribute(:closed, true)
    true
  end

  # Opens this +ForumThread+ (i.e. it will accept new +ForumPost+ children again).
  # Returns true if this ForumThread was successfully re-opened, otherwise false.
  def open
    return false unless self.closed?
    update_attribute(:closed, false)
    true
  end

  # Returns the start post of this +ForumThread+, i.e. the first +ForumPost+ of this ForumThread.
  def start_post
    forum_posts.order(created_at: :asc).first
  end

  # Returns the replies to this +ForumThread+, i.e. all +ForumPost+ children of this ForumThread, except the first one.
  def replies
    @replies ||= forum_posts[1..-1]
  end

  # Returns the number of replies to this ForumThread
  # (which is all posts minus the starting post).
  def number_of_replies
    forum_posts.count - 1
  end

  # Override destroy to set an accessor. This wel ensure the start post may be deleted as well
  def destroy
    self.is_being_destroyed = true
    super
  end

end
