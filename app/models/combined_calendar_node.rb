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
class CombinedCalendarNode < ActiveRecord::Base
  belongs_to :combined_calendar
  belongs_to :node

  validate :ensure_node_is_a_site

private

  def ensure_node_is_a_site
    errors.add(:node_id, :invalid) unless node.try(:sub_content_type) == 'Site'
  end
end
