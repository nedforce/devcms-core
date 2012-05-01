# This model is a join table between +Carrousel+ objects and other objects (polymorphic). It also holds an excerpt and the 
# position of an object in the +Carrousel+.
#
# *Specification*
# 
# Attributes
# 
# * +excerpt+ - The user supplied excerpt that will be shown for this carrousel item.
# * +item+ - The content node (polymorphic) to link to, which should be an Image, Page or NewsItem.
# * +position+ - The position of this item in its carrousel.
# * +carrousel+ - The carrousel this item belongs to.
#
# Preconditions
#
# * Requires the presence of +item+.
# * Requires the association of +carrousel+.
# * Requires the uniqueness of +item+ for the associated carrousel.
#
class CarrouselItem < ActiveRecord::Base
  has_one :active_carrousel, :class_name => 'Carrousel', :foreign_key => :current_carrousel_item_id, :dependent => :nullify
  
  belongs_to :carrousel
  belongs_to :item, :polymorphic => true

  # See the preconditions overview for an explanation of these validations.
  validates_associated    :carrousel
  validates_presence_of   :item
  validates_uniqueness_of :item_id, :scope => [ :item_type, :carrousel_id]

  # Default sort by position.
  default_scope :order => 'carrousel_items.position ASC'
  
  # Returns the title of the approved content node item.
  def title
    self.content.title
  end
  
  def title_changed?
    self.content.title_changed?
  end

  # Returns the item itself if the associated item is an Image, else the first Image child element of the content node (if any).
  def image
    self.content.is_a?(Image) ? content : self.node.children.accessible.with_content_type('Image').include_content.first.try(:content)
  end

  # Returns the node of the associated content node item.
  def node
    self.item.node
  end

  # Returns the approved content node.
  def content
    self.node.content
  end
end
