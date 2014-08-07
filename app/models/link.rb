# A link is a content node that represents either an internal or external link
# using Single Table Inheritance (STI). It has specified +acts_as_content_node+
# from Acts::ContentNode::ClassMethods.
#
# It is not possible to create +Link+ instances; use the +InternalLink+ and
# +ExternalLink+ subclasses instead.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the that will appear in the menu.
# * +description+ - A description of the link.
#
# Preconditions
#
# * Requires +title+ to have a certain length, if present.
# * Requires +description+ to have a certain length, if present.
#
class Link < ActiveRecord::Base
  acts_as_content_node

  needs_editor_approval

  # Ensure that +title+ and +description+ are set to nil if they are blank.
  before_validation :set_title_and_description_to_nil_if_blank

  # Check the length of the +title+ and +description+ attributes, if they exist.
  validates :title,       length: { in: 2..255, allow_nil: true }
  validates :description, length: { in: 2..255, allow_nil: true }
  validates :type,        inclusion: { in: ['InternalLink', 'ExternalLink'], allow_blank: false }

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  protected

  # Ensures that +title+ and +description+ are set to nil if they are blank.
  def set_title_and_description_to_nil_if_blank
    self.title       = nil if self.title.blank?
    self.description = nil if self.description.blank?
  end
end
