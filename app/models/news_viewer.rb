# This model is used to represent a news viewer that can contain
# +news_viewer_items+ and +news_viewer_archives+. A news viewer
# is somewhat like a combined news archive. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the news viewer.
# * +description+ - The description of the news viewer.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class NewsViewer < ActiveRecord::Base
  # Adds content node functionality to news viewers.
  acts_as_content_node({ 
    :allowed_roles_for_update  => %w( admin final_editor ),
    :allowed_roles_for_create  => %w( admin final_editor ),
    :allowed_roles_for_destroy => %w( admin final_editor ),
    :available_content_representations => ['content_box'],
    :has_edit_items => true,
    :has_own_feed => true 
  })

  # A +NewsViewer+ can have many +NewsViewerItem+ and +NewsViewerArchive+ children.
  has_many :news_viewer_items,    :dependent => :destroy
  has_many :news_viewer_archives, :dependent => :destroy  
  has_many :news_items,           :through => :news_viewer_items
  has_many :news_archives,        :through => :news_viewer_archives

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255

  # TODO: Documentation
  def self.tree_icon_class
    NewsArchive.tree_icon_class    
  end

  # Returns the image file name to be used for icons on the front end website.
  def icon_filename
    'news_archive.png'
  end

  # Returns the description as the tokens for indexing.
  def content_tokens
    description
  end

  # Gets accessible news items for the frontend. This method does not return unapproved content.
  def accessible_news_items_for(user, options = {})
    self.news_items.newest.find_accessible(:all, {
      :for              => user, 
      :approved_content => true,
      :order            => 'news_viewer_items.position, nodes.publication_start_date desc'
      }.merge(options))
  end

  # Returns the date when the +NewsViewer+ was last updated.
  def last_updated_at(user)
    last_item = self.news_items.newest.find_accessible(:first, :for => user, :parent => self, :order => 'nodes.publication_start_date DESC')
    last_item ? last_item.publication_start_date : self.updated_at
  end

  # Maintenance task for removing old news items and adding new ones.
  def self.update_news_items
    NewsViewer.all.each{ |nv| nv.update_news_items }
  end

  # Update the news items.
  def update_news_items
    # Destroy old items
    news_items.delete(news_items.all(:include => :node, :conditions => ['nodes.publication_start_date < ?', 2.weeks.ago]))
    # Add any news items from the archives
    news_archives.each{ |news_archive| news_archive.news_items.newest.each{ |item| self.news_items << item rescue nil }}
  end
end
