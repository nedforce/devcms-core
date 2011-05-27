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
    :allowed_child_content_types => %w( Attachment Image ),
    :has_own_content_box => true,
    :expirable => true,
    :expiration_required => false
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # A +Page+ has many +NewsletterEditionItem+ objects and many +NewsletterEdition+ through +NewsletterEditionItem+.
  has_many :newsletter_edition_items, :as => :item, :dependent => :destroy
  has_many :newsletter_editions, :through => :newsletter_edition_items

  # A +Page+ can be a carrousel item
  has_many :carrousel_items, :as => :item, :dependent => :destroy

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title, :body
  validates_length_of   :title, :in => 2..255, :allow_blank => true

  # Returns the preamble and body as the tokens for indexing.
  def content_tokens
    [ preamble, body ].compact.join(' ')
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.web_page')
  end
end