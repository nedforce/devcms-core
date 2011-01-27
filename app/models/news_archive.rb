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
  acts_as_content_node({
    :allowed_child_content_types => %w( NewsItem ),
    :allowed_roles_for_update  => %w( admin final_editor ),
    :allowed_roles_for_create  => %w( admin final_editor ),
    :allowed_roles_for_destroy => %w( admin final_editor ),
    :available_content_representations => ['content_box'],
    :has_own_feed => true,
    :children_can_be_sorted => false,
    :tree_loader_name => 'news_archives'
  })

  # Extend this class with methods to find items based on their publication date.
  acts_as_archive :items_name => :news_items

  # A +NewsArchive+ can have many +NewsItem+ children.  
  has_children :news_items, :order => 'nodes.publication_start_date DESC'

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255, :allow_blank => true

  # Returns the last update date, as seen from the perspective of the given +user+.
  def last_updated_at(user)
    ni = self.news_items.find_accessible(:first, :for => user, :include => :node, :order => 'nodes.publication_start_date DESC')
    ni ? ni.node.publication_start_date : self.updated_at
  end

  # Returns the description as the tokens for indexing.
  def content_tokens
    description
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end
end
