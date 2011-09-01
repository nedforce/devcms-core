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

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255, :allow_blank => true
  
  def calendar_items
    Event.in_calendar.scoped(:include => :node, :conditions => self.node.containing_site.descendant_conditions, :order => 'start_time DESC') do
      include CalendarItemsAssociationExtensions
    end
  end
    
  # Returns the last update date, as seen from the perspective of the given +user+.
  def last_updated_at(user)
    ci = self.calendar_items.find_accessible(:first, :select => 'events.created_at', :order => 'events.created_at DESC', :for => user)
    ci ? ci.created_at : self.updated_at
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
end
