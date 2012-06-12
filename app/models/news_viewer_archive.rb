# This model is used to represent a news viewer archive, that belongs to
# a +news_viewer+. It is associated with a +news_archive+.
#
# *Specification*
#
# Attributes
#
# * +news_viewer+ - The news viewer this news viewer archive belongs to.
# * +news_archive+ - The news archive this news viewer archive belongs to.
#
# Preconditions
#
# * Requires the +news_archive+ this +news_viewer_archive+ is associated with, to be unique for every +news_viewer+.
#
class NewsViewerArchive < ActiveRecord::Base  
  belongs_to :news_archive
  belongs_to :news_viewer

  # See the preconditions overview for an explanation of these validations.
  validates_uniqueness_of :news_archive_id, :scope => :news_viewer_id

  # Create direct links (i.e. news viewer items) between the news items in the associated news archive and
  # the news viewer (this news viewer archive belongs to).
  after_create{ |viewer_archive| viewer_archive.news_archive.news_items.newest.each{ |item| viewer_archive.news_viewer.news_items << item rescue nil }}

  # Remove direct links (i.e. news viewer items) from the news viewer, which are also included in this news viewer archive.
  after_destroy{ |viewer_archive| viewer_archive.news_viewer.news_items.delete(viewer_archive.news_archive.news_items) if viewer_archive.news_viewer }
end
