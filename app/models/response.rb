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
# * +description_before_contact_fields+ - The description of the contact form (printed before the actual contact fields).
# * +description_after_contact_fields+ - The description of the contact form (printed after the actual contact fields).
# * +send_method+ - The way of storing/sending the email. See constants
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +email_address+.
# * Requires +email_address+ to be a valid email address.
#
class Response < ActiveRecord::Base
  belongs_to :contact_form
  has_many :response_fields, :dependent => :destroy
  
end
