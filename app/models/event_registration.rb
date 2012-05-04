# An EventRegistration is used to let users registrate for events. The user has
# to specify with the amount of people they are coming with.
# 
# *Specification*
# 
# Attributes
# 
# * +event_id+ - Refers to the event this registration is for
# * +user_id+ - Refers to the user that registrated
# * +people_count+ - How many people the +user+ takes to the +event+.
#
# Preconditions
#
# * Requires +event+ and +user+ to be present.
# * Requires +people_count+ to be a positive, non-zero integer
#
class EventRegistration < ActiveRecord::Base

  belongs_to :event
  belongs_to :user
  
  validates_presence_of :event
  validates_presence_of :user
  validates_numericality_of :people_count, :greater_than => 0, :only_integer => true
  
  validate :user_has_full_name
  
  private
  
  def user_has_full_name
    errors.add(:user, 'moet een achternaam ingesteld hebben in het profiel') if user.surname.strip.empty?
  end

end
