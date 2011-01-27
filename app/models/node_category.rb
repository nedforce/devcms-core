# A NodeCategory is used to group nodes.
# 
# *Specification*
# 
# Attributes
# 
# * +node+ - The node this node category is associated with.
# * +category+ - The category this node category is associated with.
#
# Preconditions
#
# * Requires +node+ to be present.
# * Requires +category+ to be present.
# * Requires a +node_category+ to have a unique +category+ for every +node+.
#
class NodeCategory < ActiveRecord::Base

  belongs_to :node
  belongs_to :category

  # See the preconditions overview for an explanation of these validations. 
  validates_uniqueness_of :category_id, :scope => :node_id
  validates_presence_of   :node, :category
end
