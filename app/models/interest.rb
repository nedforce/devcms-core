# This model is used to represent an interest (of one or many users).
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the interest.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class Interest < ActiveRecord::Base  
  has_and_belongs_to_many :users

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
end
