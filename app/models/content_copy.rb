# A content copy is a content node that represents a copy of another content node
# i.e., it acts as a symbolic link. It has specified +acts_as_content_node+
# from Acts::ContentNode::ClassMethods.
#
# To prevent circular references, it is not allowed that the linked Node instance
# (as identified by +copied_node+) is associated with a ContentCopy content node.
#
# NOTE: +node+ is the associated Node, +copied_node+ is the Node that is copied.
#
# *Specification*
#
# Attributes
#
# * +copied_node+ - The node whose content this content copy copies.
#
# Preconditions
#
# * Requires +copied_node_id+ to be present and point to a Node instance.
# * Requires the linked Node to not be associated with a ContentCopy content node.
# * Requires the linked Node to be associated with a content node that allows to be copied.
# * Requires the linked Node to not be a root node.
#
class ContentCopy < ActiveRecord::Base
  # Adds content node functionality to content copies.
  acts_as_content_node({
    :allowed_roles_for_update => [],
    :show_in_menu => false,
    :copyable => false
  })

  # This content type needs approval when created or altered by an editor
  needs_editor_approval

  # The node whose content this content copy copies.
  belongs_to :copied_node, :class_name => "Node", :foreign_key => 'copied_node_id'

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :copied_node
  validates_numericality_of :copied_node_id
  validate :ensure_copied_node_is_not_associated_with_a_content_copy_content_node
  validate :ensure_copied_node_is_associated_with_a_copyable_content_node

  before_validation :copy_publication_and_expiration_dates

  def title
    self.copied_node.content.title
  end

  def title_changed?
    self.copied_node.content.title_changed?
  end

  # Returns the CSS class name to be used for icons in tree view.
  def tree_icon_class
    self.copied_node.content_type.underscore + '_icon'
  end

  # Returns the image file name to be used for icons in a Section's show view.
  def icon_filename
    self.copied_node.content.icon_filename
  end

  # Returns the content class of the copied node.
  def copied_content_class
    self.copied_node.blank? ? self.class : copied_node.content_class
  end

  # Try to delegate unknown methods to the copied node's content
  def method_missing(method_name, *args)
    if self.copied_node.present? && self.copied_node.content.respond_to?(method_name)
      self.copied_node.content.send(method_name, *args)
    else
      super
    end
  end

  # Necessary because we override method_missing
  def respond_to?(*args)
    if self.copied_node.present? && self.copied_node.content.respond_to?(*args)
      true
    else
      super
    end
  end

protected

  def copy_publication_and_expiration_dates
    return unless self.copied_node.present?

    self.expires_on             = self.copied_node.expires_on
    self.publication_start_date = self.copied_node.publication_start_date
    self.publication_end_date   = self.copied_node.publication_end_date
  end

  # To prevent circular references, we must ensure that the copied Node instance
  # (as identified by +copied_node+) is not associated with a ContentCopy content
  # node.
  def ensure_copied_node_is_not_associated_with_a_content_copy_content_node
    errors.add(:base, :copied_content_cannot_be_content_copy) if self.copied_node && self.copied_node.content.is_a?(ContentCopy)
  end

  # Ensure the copied node is associated with a content node that allows to be copied.
  def ensure_copied_node_is_associated_with_a_copyable_content_node
    errors.add(:base, :copied_content_must_be_copyable) if self.copied_node && !self.copied_node.content_type_configuration[:copyable]
  end
end
