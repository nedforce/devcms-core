# An internal link is a content node that represents a link to a +Node+
# instance.
#
# To prevent multiple redirects, or even infinite redirection, it is not allowed
# that the linked +Node+ instance (as identified by +linked_node+) is associated
# with a +Link+ content node.
#
# NOTE: +node+ is the associated +Node+, +linked_node+ is the +Node+ that is
#       linked to.
#
# *Specification*
#
# Attributes
#
# * +linked_node+ - The node that this internal link links to.
#
# NOTE: For other attributes, see the +Link+ model.
#
# Preconditions
#
# * Requires +linked_node_id+ to be present and point to a +Node+ instance.
# * The linked +Node+ may not be associated with a +Link+ content node.
# * The linked +Node+ must be in the same +Site+ as the internal link
class InternalLink < Link
  # Adds content node functionality to links.
  acts_as_content_node(
    available_content_representations: ['content_box'],
    show_content_box_header:           false,
    controller_name:                   'internal_links'
  )

  needs_editor_approval

  # The node that this internal link links to.
  belongs_to :linked_node, class_name: 'Node'

  # See the preconditions overview for an explanation of these validations.
  validates :linked_node, presence: true
  validates_numericality_of :linked_node_id, allow_nil: true
  validate :linked_node_is_not_associated_with_a_link_content_node
  validate :linked_node_is_contained_in_same_site

  # Overrides the +content_title+ method of the +acts_as_content_node+ mixin.
  def content_title
    title.blank? ? linked_node.content_title : title
  end

  protected

  # To prevent multiple redirects, or even infinite redirection, we must ensure
  # that the linked +Node+ instance (as identified by +linked_node+) is not
  # with a +Link+ content node.
  def linked_node_is_not_associated_with_a_link_content_node
    errors.add(:base, :not_linked_node) if linked_node && linked_node.content.is_a?(Link)
  end

  # Ensure the linked node is contained in the same site node, so that
  # inter-site links are impossible.
  def linked_node_is_contained_in_same_site
    errors.add(:base, :linked_node_must_be_contained_in_same_site) if linked_node && parent && !parent.containing_site.self_and_descendants.exists?(id: linked_node_id)
  end
end
