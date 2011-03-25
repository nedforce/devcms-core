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
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :copyable => false
  })

  # Extend this class with methods to find items based on their publication date.
  #acts_as_archive :date_time_field => :last_update_date, :items => :forum_threads

  # A +ForumTopic+ belongs to a +Forum+.
  has_parent :forum

  # A +ForumTopic+ can have many +ForumThread+ children.
  has_many :forum_threads, :dependent => :destroy, :extend => FindAccessible::AssociationExtension

  # See the preconditions overview for an explanation of these validations.  
  validates_presence_of   :title, :description, :forum
  validates_uniqueness_of :title
  validates_length_of     :title, :in => 2..255

  # Returns the child ForumThread objects, ordered by their +last_update_date+ values.
  def forum_threads_by_last_update_date(args = {})
    # Custom SQL query to minimize performance hit
    # TODO: Not too keen on the INNER JOIN here, any way to avoid that? DB caching of created_at?
    #
    # Reply (2010.07.20 RvdH): Add a field to ForumTopic that keeps the last created_at of a child?
    # Or use the updated_at field of ForumTopic?
    self.forum_threads.all(
      {
        :select => 'forum_threads.id, forum_threads.title, forum_threads.user_id, MAX(forum_posts.created_at) AS last_update_date', 
        :joins  => :forum_posts,
        :group  => 'forum_threads.id, forum_threads.title, forum_threads.user_id', 
        :order  => 'last_update_date DESC'
      }.merge(args)
    )
  end

  # Returns the date at which this ForumTopic was last updated.
  # If this ForumTopic contains no ForumThread objects, then the creation date is returned.
  # Otherwise, the maximum last update date of all its child ForumThread objects is returned.
  def last_update_date
    if self.forum_threads.empty?
      self.created_at
    else
      # TODO: Not too keen on the INNER JOIN here, any way to avoid that? DB caching of created_at?
      self.forum_threads.maximum('forum_posts.created_at', :joins => :forum_posts)
    end
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
