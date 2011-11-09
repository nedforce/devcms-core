# A LinksBox is a content node that represents a collection of Links.
class LinksBox < ActiveRecord::Base
  
  acts_as_content_node({
    :allowed_child_content_types => %w(
      Image InternalLink ExternalLink
    ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_update  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box'],
    :has_own_content_box => false,
    :controller_name => 'links_boxes',
    :show_in_menu => false,
    :copyable => false
  })
  
  # This content type needs approval when created or altered by an editor.
  needs_editor_approval
  
  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :title
  validates_length_of       :title, :in => 2..255
  
  # Returns the last update date, as seen from the perspective of the given +user+.
  def last_updated_at(user)
    conditions = [ "NOT nodes.content_type IN (?)", [ 'Image', 'Attachment' ] ]
    descendant_conditions = self.node.descendant_conditions
    conditions.first << " AND " << descendant_conditions.shift
    conditions.concat(descendant_conditions)
    child = Node.find_accessible(:first, :for => user, :select => 'nodes.updated_at', :order => 'nodes.updated_at DESC', :conditions => conditions)
    child ? child.updated_at : self.updated_at
  end
  
  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
  
  # Returns the children content nodes of this section for the given +user+.
  # By default images and attachments are excluded.
  def accessible_children_for(user, exclude_content_types = ['Image','Attachment']) 
    node.accessible_content_children(:for => user, :exclude_content_type => exclude_content_types)
  end
  
  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end
end
