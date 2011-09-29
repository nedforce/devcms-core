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

  # Prevent a +Link+ from being directly instantiated.
  validate :should_not_be_directly_instantiated

  # Check the length of the +title+ and +description+ attributes, if they exist.
  validates_length_of :title,       :in => 2..255, :allow_nil => true
  validates_length_of :description, :in => 2..255, :allow_nil => true

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  protected

  # Prevents a +Link+ from being directly instantiated.
  def should_not_be_directly_instantiated
    errors.add_to_base(:not_direct) unless self[:type]
  end

  # Ensures that +title+ and +description+ are set to nil if they are blank.
  def set_title_and_description_to_nil_if_blank
    self.title       = nil if self.title.blank?
    self.description = nil if self.description.blank?
  end
end
