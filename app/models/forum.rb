# This model is used to represent a forum that can contain multiple forum topics, 
# which are represented using +ForumTopic+ objects. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the forum.
# * +description+ - The description of the forum.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the uniqueness of +title+.
#
# Child/parent type constraints
# 
#  * A +Forum+ only accepts +ForumTopic+ children.
#
class Forum < ActiveRecord::Base
  
  # Adds content node functionality to forums.
  acts_as_content_node({
    :allowed_child_content_types => %w( ForumTopic ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box'],
    :children_can_be_sorted => false
  })
      
  # A +Forum+ can have many +ForumTopic+ children.
  has_children :forum_topics, :order => 'title'
    
  # See the preconditions overview for an explanation of these validations.
  validates_presence_of   :title
  validates_uniqueness_of :title
  validates_length_of     :title, :in => 2..255

  # Finds the +limit+ last updated +ForumThread+ grandchildren.
  def find_last_updated_forum_threads(limit = 5, args = {})
    return [] if limit <= 0
    # Custom SQL query to minimize performance hit
    # TODO: Not too keen on the INNER JOINs here, any way to avoid these? DB caching of created_at?
    ForumThread.find(:all,
      {
        :select     => 'forum_threads.id, forum_threads.title, forum_threads.forum_topic_id, MAX(forum_posts.created_at) AS last_update_date', 
        :from       => '(forum_threads ',
        :joins      => 'INNER JOIN forum_topics ON forum_threads.forum_topic_id = forum_topics.id) INNER JOIN forum_posts ON forum_posts.forum_thread_id = forum_threads.id',
        :conditions => { :forum_topic_id => forum_topics },
        :group      => 'forum_threads.id, forum_threads.title, forum_threads.forum_topic_id', 
        :limit      => limit,
        :order      => 'last_update_date DESC'
      }.merge(args)
    )
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
