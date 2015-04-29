# This model is used to represent a news item. A news item is contained within
# a news archive, which in turn is represented by the NewsArchive model.
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the news item.
# * +preamble+ - The preamble of the news item.
# * +body+ - The body of the news item.
# * +meta_description+ - The meta description of the news item.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +body+.
# * Requires the presence of +news_archive+.
# * Requires the length of +meta_description+ to be maximum 160 characters.
#
# Child/parent type constraints
#
#  * A NewsItem only accepts Attachment and Image children.
#  * A NewsItem can only be inserted into NewsArchive nodes.
#
class NewsItem < ActiveRecord::Base
  # Adds content node functionality to news items.
  acts_as_content_node(
    allowed_child_content_types: %w( Attachment AttachmentTheme Image ),
    show_in_menu:                false,
    copyable:                    false
  )

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # A +NewsItem+ belongs to a +NewsArchive+.
  has_parent :news_archive

  # A +NewsItem+ has many +NewsletterEditionItem+ objects and many +NewsletterEdition+ through +NewsletterEditionItem+.
  has_many :newsletter_edition_items, as: :item, dependent: :destroy
  has_many :newsletter_editions,      through: :newsletter_edition_items

  # A +NewsItem+ can be a carrousel item
  has_many :carrousel_items, as: :item, dependent: :destroy

  # A +NewsItem+ has many +NewsViewerItem+ objects, destroy if this object is destroyed.
  has_many :news_viewer_items, dependent: :destroy

  # See the preconditions overview for an explanation of these validations.
  validates :title,            presence: true, length: { maximum: 255 }
  validates :body,             presence: true
  validates :news_archive,     presence: true
  validates :meta_description, length: { maximum: 160 }

  scope :newest, lambda { includes(:node).where(['nodes.publication_start_date >= ?', (Settler['news_viewer_time_period'] ? Settler['news_viewer_time_period'].to_i : 2).weeks.ago]) } 

  after_paranoid_delete :remove_associated_content

  # Alternative text for tree nodes.
  def tree_text(node)
    "#{node.publication_start_date.day}/#{node.publication_start_date.month} #{self.title}"
  end

  # Returns the preamble and body as the tokens for indexing.
  def content_tokens
    [preamble, body].join(' ')
  end

  # Returns a URL alias for a given +node+.
  def path_for_url_alias(node)
    "#{node.publication_start_date.year}/#{node.publication_start_date.month}/#{node.publication_start_date.day}/#{self.title}"
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.news_item')
  end

  protected

  def remove_associated_content
    self.newsletter_edition_items.destroy_all
    self.carrousel_items.destroy_all
    self.news_viewer_items.destroy_all
  end
end
