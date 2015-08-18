# This model is used to represent a newsletter archive that can contain multiple
# newsletter editions, which are represented using +NewsletterEdition+ objects.
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the newsletter archive.
# * +description+ - The description of the newsletter archive.
# * +from_email_address+ - The email address that is used for the from field for
#                          the associated newsletter editions.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires +from_email_address+ to be a valid email address.
#
class NewsletterArchive < ActiveRecord::Base
  # Adds content node functionality to news archives.
  acts_as_content_node(
    allowed_child_content_types:       %w( NewsletterEdition Image ),
    allowed_roles_for_update:          %w( admin final_editor ),
    allowed_roles_for_create:          %w( admin final_editor ),
    allowed_roles_for_destroy:         %w( admin final_editor ),
    available_content_representations: ['content_box'],
    children_can_be_sorted:            false,
    tree_loader_name:                  'newsletter_archives'
  )

  # Extend this class with methods to find items based on their publication
  # date.
  acts_as_archive items_name: :newsletter_editions

  # A +NewsletterArchive+ can have many +NewsletterEdition+ children.
  has_children :newsletter_editions, order: 'nodes.publication_start_date DESC'

  # A +NewsletterArchive+ has and belongs to many +User+ objects (i.e.
  # subscribed users).
  #has_and_belongs_to_many :users

  has_many :newsletter_archives_users
  has_many :users, through: :newsletter_archives_users

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }

  validates :from_email_address, email: { allow_blank: true }

  # Returns the last update date
  def last_updated_at
    nle = newsletter_editions.accessible.first(include: :node, conditions: ['newsletter_editions.published <> ?', 'unpublished'], order: 'nodes.publication_start_date DESC')
    last_nle_update = nle ? nle.node.publication_start_date : nil

    [last_nle_update, updated_at].compact.max
  end

  # Returns true if this +NewsletterArchive+ has a subscription for the +User+
  # specified by +user+, else false.
  def has_subscription_for?(user)
    users.exists?(id: user.id)
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end
end
