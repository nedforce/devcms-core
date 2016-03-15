# This model is used to represent a news viewer item, that belongs to
# a +news_viewer+. It is associated with a +news_item+.
#
# *Specification*
#
# Attributes
#
# * +news_viewer+ - The news viewer this news viewer item belongs to.
# * +news_item+ - The news item this news viewer item belongs to.
#
# Preconditions
#
# * Requires the +news_item+ this +news_viewer_item+ is associated with, to be unique for every +news_viewer+.
#
class NewsViewerItem < ActiveRecord::Base
  belongs_to :news_item
  belongs_to :news_viewer

  # The associated news items are included by default.
  default_scope ->{ includes(:news_item).order(:position) }

  # See the preconditions overview for an explanation of these validations.
  validates_uniqueness_of :news_item_id, scope: :news_viewer_id
end
