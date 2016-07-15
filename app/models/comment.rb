# This model represents a comment, which can be added to a node
# It was part of Juixe::Act::Commentable, but added as a model
# to be able to extend the class with validators.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the comment.
# * +comment+ - The actual comment.
# * +user+ - The user that commented.
# * +user_name+ - The user name of the person that commented.
# * +commentable_id+ - The node (polymorphic) of the referenced object.
# * +commentable_type+ - The type of the referenced object.
#
# Preconditions
#
# * Requires the presence of +user+.
# * Requires the presence of +user_name+.
# * Requires the presence of +commentable+.
# * Requires the presence of +comment+.
#
class Comment < ActiveRecord::Base
  # A Comment belongs polymorphically to a node.
  belongs_to :commentable, polymorphic: true
  belongs_to :node,        foreign_key: 'commentable_id'

  # Comments belong to a user.
  belongs_to :user
  validates :user, presence: true # Remove this validation to allow unauthenticated comments.

  # Set the +user_name+ to the login of the +user+.
  before_validation :set_user_name, on: :create

  # See the preconditions overview for an explanation of these validations.
  validates :commentable, presence: true
  validates :comment,     presence: true, length: { maximum: 500 }
  validates :user_name,   presence: true, length: { maximum: 255 }

  def self.parent_type
    Node
  end

  # Returns comments that are editable for the given +user+.
  def self.editable_comments_for(user, options = {})
    if user.has_role?('editor')
      scope = user.comments.includes(:node)
      scope = scope.order(options[:order]) if options[:order]
      scope
    else
      scope = Comment.includes(:node)
      scope = scope.order(options[:order]) if options[:order]
      scope.select { |comment| comment.user == user || user.has_role_on?(%w(admin final_editor), comment.node) }
    end
  end

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  def self.find_comments_for_commentable(commentable_str, commentable_id)
    Comment.where('commentable_type = ? AND commentable_id = ?', commentable_str, commentable_id).order(created_at: :desc)
  end

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  protected

  # Set the +user_name+ to the login of the +user+.
  def set_user_name
    self.user_name = user.login if user
  end
end
