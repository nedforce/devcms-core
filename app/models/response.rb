# This model is used to represent a response from a contact_form
#
# A +Response+ has many +ResponseField+ objects.
#
# *Specification*
# 
# Attributes
# 
# * +ip+ - The ip adress of the sender
# * +time+ - The time when the response is sent
#
# Preconditions
#
# * Requires the presence of +ip+, +time+.
#
class Response < ActiveRecord::Base
  belongs_to :contact_form
  has_many :response_fields, :dependent => :destroy
  
  validates_presence_of :contact_form_id, :ip, :time
  
end
