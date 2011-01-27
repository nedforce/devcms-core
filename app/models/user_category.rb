# A UserCategory is used to group users. Thus, it can contain 
# many users, each represented with the User content type.
# 
# *Specification*
# 
# Attributes
# 
# * +user+ - The associated user.
# * +category+ - The associated category.
#
# Preconditions
#
# * Requires +user+ to be present.
# * Requires +category+ to be present.
# * Requires a +user_category+ to have a unique +category+ for a +user+.
#
class UserCategory < ActiveRecord::Base

  belongs_to :user
  belongs_to :category

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of   :user, :category
  validates_uniqueness_of :category_id, :scope => :user_id
end
