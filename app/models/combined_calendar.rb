# This model is used to represent a combined calendar that always contains all 
# existing events (calendar items), which are represented using +CalendarItem+ 
# objects. It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the combined calendar.
# * +description+ - The description of the combined calendar.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class CombinedCalendar < ActiveRecord::Base
  
  # Adds content node functionality to combined calendars.
  acts_as_content_node({
    :allowed_roles_for_create  => %w( admin final_editor ),
    :allowed_roles_for_destroy => %w( admin final_editor ),
    :available_content_representations => ['content_box'],
    :has_own_feed => true
  })
  
  has_many :combined_calendar_nodes, :dependent => :destroy
  has_many :sites, :through => :combined_calendar_nodes, :source => :node

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255, :allow_blank => true
  
  def calendar_items
    return @calendar_items_scope if @calendar_items_scope

    containing_site = self.node.containing_site

    # Exclude other sites
    nodes_to_exclude = containing_site.descendants.with_content_type('Site') - sites
    
    # Exclude private sections
    nodes_to_exclude += containing_site.descendants.sections.private

    # Scope within all accessible calendars
    accessible_calendar_node_child_ancestries = containing_site.descendants.accessible.exclude_subtrees_of(nodes_to_exclude).with_content_type('Calendar').all.map { |n| n.child_ancestry }
    
    @calendar_items_scope = Event.scoped(:include => :node, :conditions => { 'nodes.ancestry' => accessible_calendar_node_child_ancestries }, :order => 'start_time DESC') do
      include CalendarItemsAssociationExtensions
    end
  end
    
  # Returns the last update date
  def last_updated_at
    [ self.calendar_items.accessible.maximum('nodes.created_at'), self.updated_at ].compact.max
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
