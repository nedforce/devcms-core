# This model is used to represent a weblog. A weblog is contained within a
# weblog archive, which in turn is represented by the +WeblogArchive+ model.
# Each +Weblog+ is also associated with one +User+, who is the owner of the
# +Weblog+.
#
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the weblog.
# * +description+ - The description of the weblog.
# * +weblog_archive+ - The weblog archive this weblog belongs to.
# * +user+ - The user this weblog belongs to.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +weblog_archive+.
# * Requires the presence of +user+.
#
# * Requires the uniqueness of +title+ and +user+, within a given
#   +WeblogArchive+.
#
# Child/parent type constraints
#
#  * A +Weblog+ only accepts +WeblogPost+ children.
#  * A +Weblog+ can only be inserted into +WeblogArchive+ nodes.
#
class Weblog < ActiveRecord::Base
  # Adds content node functionality to weblogs.
  acts_as_content_node({
    allowed_child_content_types:       %w( WeblogPost ),
    allowed_roles_for_create:          [],
    allowed_roles_for_update:          %w( admin final_editor ),
    allowed_roles_for_destroy:         %w( admin final_editor ),
    available_content_representations: ['content_box'],
    show_in_menu:                      false,
    copyable:                          false,
    has_own_feed:                      true,
    children_can_be_sorted:            false,
    tree_loader_name:                  'weblogs',
    nested_resource:                   true
  })

  # Extend this class with methods to find items based on their
  # publication date.
  acts_as_archive items_name: :weblog_posts

  # A +Weblog+ belongs to a +WeblogArchive+.
  has_parent :weblog_archive

  # A +Weblog+ has many +WeblogPost+ objects.
  has_children :weblog_posts, order: 'nodes.publication_start_date DESC'

  # A +Weblog+ belongs to a +User+.
  belongs_to :user

  # See the preconditions overview for an explanation of these validations.
  validates :title,          presence: true, length: { maximum: 255 }
  validates :weblog_archive, presence: true
  validates :user,           presence: true

  # Returns true if this +Weblog+ is owned by the given +User+, else false.
  def is_owned_by_user?(user)
    self.user == user
  end

  # Finds the +limit+ last published +WeblogPost+ children
  def find_last_published_weblog_posts(limit = 5)
    return [] if limit <= 0

    weblog_posts.accessible.all(limit: limit)
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
