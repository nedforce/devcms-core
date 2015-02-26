# This model is used to represent a newsletter edition queue that belongs to
# a newsletter edition and a specific user.
#
# *Specification*
#
# Attributes
#
# * +newsletter_edition+ - The newsletter edition this newsletter edition queue
#                          belongs to.
# * +user+ - The user this newsletter edition queue belongs to.
#
# Preconditions
#
# * Requires the presence of +user+.
# * Requires the presence of +newsletter_edition+.
# * Requires the +newsletter_edition_queue+ to belong to a unique +user+ for
#   every +newsletter_edition+.
#
class NewsletterEditionQueue < ActiveRecord::Base
  belongs_to :user
  belongs_to :newsletter_edition

  # See the preconditions overview for an explanation of these validations.
  validates :user,                  presence: true
  validates :newsletter_edition,    presence: true
  validates :user_id,               numericality: true, uniqueness: { scope: :newsletter_edition_id }
  validates :newsletter_edition_id, numericality: true
end
