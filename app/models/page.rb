# A page is a content node that contains static text. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+    - The title of the page.
# * +body+     - The body of the page.
# * +preamble+ - The preamble of the page.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +body+.
#
# Child/parent type constraints
#
#  * A +Page+ only accepts +Attachment+ and +Image+ nodes.
#  * A +Page+ can be inserted into nodes of any accepting type.
#
class Page < ActiveRecord::Base
  # Adds content node functionality to pages.
  acts_as_content_node({
    allowed_child_content_types:       %w( Attachment AttachmentTheme Image ),
    available_content_representations: ['content_box'],
    has_own_content_box:               true,
    expirable:                         true,
    expiration_required:               true
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # A +Page+ has many +NewsletterEditionItem+ objects and many +NewsletterEdition+ through +NewsletterEditionItem+.
  has_many :newsletter_edition_items, as: :item, dependent: :destroy
  has_many :newsletter_editions,      through: :newsletter_edition_items

  # A +Page+ can be a carrousel item
  has_many :carrousel_items, as: :item, dependent: :destroy

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }
  validates :body,  presence: true

  after_paranoid_delete :remove_associated_content

  # Returns the preamble and body as the tokens for indexing.
  def content_tokens
    [preamble, body].join(' ')
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.web_page')
  end

  def has_related_content?
    node.tags.empty?
  end

protected

  def remove_associated_content
    self.newsletter_edition_items.destroy_all
    self.carrousel_items.destroy_all
  end
end
