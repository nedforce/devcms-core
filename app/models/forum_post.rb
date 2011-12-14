# This model is used to represent a forum post, which belongs to a particular
# forum thread, which in turn is represented by ForumThread.
#
# *Specification*
#
# Attributes
#
# * +user+ - The poster (if available).
# * +user_name+ - The name of the poster.
# * +forum_thread+ - The containing forum thread.
# * +body+ - The body of the forum post.
#
# Preconditions
#
# * Requires the presence of +user+.
# * Requires the presence of +user_name+.
# * Requires the presence of +forum_thread+.
# * Requires the presence of +body+.
#
# * Requires the associated +ForumThread+ to be open when the +ForumPost+ is created.
#
# Postconditions
#
# * Requires the +ForumPost+ to be not the start post of a +ForumThread+ to allow it to be destroyed.
#
class ForumPost < ActiveRecord::Base

  # A ForumPost belongs to a ForumThread.
  belongs_to :forum_thread

  # A ForumPost belongs to a User (i.e. the poster).
  belongs_to :user

  # Send an email to the thread owner after a new post has been created.
  after_create :notify_thread_owner

  # See the preconditions overview for an explanation of these validations.
  before_validation_on_create :set_user_name
  validates_presence_of :body, :forum_thread, :user_name, :user
  validates_length_of   :body, :in => 1..5000

  validates_numericality_of :user_id, :forum_thread_id, :allow_nil => false
  validate_on_create :ensure_thread_not_closed
  
  # Note: NOT ForumThread, as ForumThreads are no content nodes either
  def self.parent_type
    ForumTopic
  end

  # Returns replies only.
  def self.replies(options = {})
    ForumPost.all(options).reject{|fp| fp.is_start_post? }
  end

  # Returns the comments that can be edited by the given +user+.
  def self.editable_comments_for(user, options = {})
    if user.has_role?('editor')
      user.forum_posts({ :include => :forum_thread }.merge(options)).reject{|fp| fp.is_start_post? }
    else
      ForumPost.replies({ :include => { :forum_thread => :forum_topic } }.merge(options)).select{ |post| post.user == user || user.has_role_on?(['admin', 'final_editor'], post.forum_thread.forum_topic.node) }
    end
  end

  # Returns true if this ForumPost is created by the given +user+, else false.
  def is_owned_by_user?(user)
    !self.user.nil? && self.user == user
  end

  # Returns true if this ForumPost is the first post of the associated ForumThread, else false.
  def is_start_post?
    self.forum_thread.blank? ? false : self == self.forum_thread.start_post
  end

  # Added to make ForumPosts similar to Comments. This is used to allow admins
  # to update and delete reactions of weblog and forum posts in the same view.
  def comment; body end
  def comment=(text); self.body = text  end

  protected

  # Ensures that the ForumThread to which the new ForumPost is added is not closed.
  def ensure_thread_not_closed
    errors.add_to_base(:cannot_be_added_to_closed_thread) if self.forum_thread && self.forum_thread.closed?
  end

  # Set the +user_name+ to the login of the +user+.
  def set_user_name
    self.user_name = self.user.login if self.user
  end

  # Ensure the +ForumPost+ cannot be destroyed if it is the start post of a +ForumThread+.
  def before_destroy
    errors.add_to_base(:cannot_destroy_first_post) if is_start_post?
    !is_start_post?
  end

  # Notify the thread owner of a new forum post by sending an email.
  def notify_thread_owner
    UserMailer.deliver_new_forum_post_notification(self.forum_thread.user, self) unless is_start_post?
  end
end
