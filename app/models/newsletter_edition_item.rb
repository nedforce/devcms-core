# This model is a join table between +NewsEdition+ objects and other objects (polymorphic). It also holds the position of an
# object in a +NewsletterEdition+.
#
# *Specification*
#
# Attributes
#
# * +newsletter_edition+ - The newsletter edition the item belongs to.
# * +item_type+ - The type (class) of the referenced object.
# * +item_id+ - The id of the referenced object.
# * +position+ - The position of the item in the newsletter edition.
#
# Preconditions
#
# * Requires the presence of +item+.
# * Requires the presence of +newsletter_edition+.
# * Requires +item+ to be unique for a +newsletter_edition+.
# * Requires +position+ to be numerical, if present.
#
class NewsletterEditionItem < ActiveRecord::Base
  belongs_to :newsletter_edition
  belongs_to :item, polymorphic: true

  # See the preconditions overview for an explanation of these validations.
  validates :newsletter_edition, presence: true
  validates :item,               presence: true
  validates :position,           numericality: { allow_blank: true }
  validates_numericality_of :newsletter_edition_id, :item_id
  validates_uniqueness_of   :item_id,  :scope => [ :item_type, :newsletter_edition_id ]
end
