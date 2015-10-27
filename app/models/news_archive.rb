require 'rss/2.0'

# This model is used to represent a news archive that can contain multiple news
# items, which are represented using +NewsItem+ objects. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the news archive.
# * +description+ - The description of the news archive.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class NewsArchive < ActiveRecord::Base
  # Adds content node functionality to news archives.
  acts_as_content_node(
    allowed_child_content_types:       %w( NewsItem ),
    allowed_roles_for_update:          %w( admin final_editor ),
    allowed_roles_for_create:          %w( admin final_editor ),
    allowed_roles_for_destroy:         %w( admin final_editor ),
    available_content_representations: ['content_box'],
    has_own_feed:                      true,
    children_can_be_sorted:            false,
    tree_loader_name:                  'news_archives'
  )

  scope :not_archived, ->{ where(archived: false) }

  # Extend this class with methods to find items based on their
  # publication date.
  acts_as_archive items_name: :news_items

  # A +NewsArchive+ can have many +NewsItem+ children.
  has_children :news_items, order: 'nodes.publication_start_date DESC'

  has_many :news_viewer_archives
  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }

  # Returns the description as the tokens for indexing.
  def content_tokens
    description
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end

  def last_updated_at
    node.descendants.maximum(:updated_at) || updated_at
  end
end
