# This model is used to represent a research theme. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the research theme.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class Theme < ActiveRecord::Base
  # Adds content node functionality to research themes.
  acts_as_content_node({
    :allowed_child_content_types => %w(),
    :allowed_roles_for_create  => %w(),
    :allowed_roles_for_update  => %w(),
    :allowed_roles_for_destroy => %w(),
    :copyable => false
  })

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255, :allow_blank => true

  def content_depth
    if node.parent.content.respond_to? :content_depth
      node.parent.content.content_depth + 1
    else
      1
    end
  end
  
  # Returns the number of descendant themes of this theme +1 (this theme).
  def number_of_themes
    descendant_themes.count + 1
  end
  
  def descendant_themes
    node.descendants.with_content_type(self.class.name).accessible
  end
  
  def sub_themes
    node.children.with_content_type(self.class.name).accessible
  end
  
  def content_descendants
    node.descendants.exclude_content_types(self.class.name).accessible
  end 
    
  def content_children
    node.children.exclude_content_types(self.class.name).accessible
  end
  # Returns the number of +ResearchReport+ objects directly associated with this theme.
  def number_of_children
    content_children.count
  end
  
  def depth
    node.parent.content.is_a?(Theme) ? node.parent.content.depth : 1
  end
end
