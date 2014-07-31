# A template is a layout that is to be used while rendering a node.
#
# *Specification*
# 
# Attributes
#
# * +filename+ - The on-disk filename of the layout to render.
# * +nodes+ - The nodes that have specified this template. Note that there may
#             be more nodes that are using this template, because templates are
#             inherited by nodes that do not specify their own template.
# * +title+ - The title of the template.
# * +description+ - The description of the template.
#
# Preconditions
#
# * Requires the presence of +title+ and +filename+.
# * Requires the uniqueness of +title+ and +filename+.
#
# Postconditions
#
# * Can not be destroyed when there are nodes referring to this template.
#
class Template < ActiveRecord::Base
  has_many :nodes

  # See the preconditions overview for an explanation of these validations.
  validates :title,    :presence => true, :uniqueness => true, :length => { :in => 2..255 }
  validates :filename, :presence => true, :uniqueness => true, :length => { :in => 2..255 }

  # Prevents destruction if there are still nodes referencing this template.
  before_destroy :restrict_when_referenced

  # Returns the full path name of this template.
  def full_path
    "templates/#{self.filename}"
  end

  protected

  # Prevents destruction if there are still nodes referencing this template.
  def restrict_when_referenced
    return false if nodes.count > 0
  end
end
