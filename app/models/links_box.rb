# A Site is a content node that represents the whole site or a subsite of the site, as identified by a domain. All the content
# of a (sub-)site is scoped within a Site node. It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +domain+ - The domain of the site, can be left blank if it's the 'top' site.
#
# Preconditions
#
# * Requires the format of +domain+ to conform to VALID_DOMAIN_REGEXP, if specified.
class LinksBox < Section
  
  acts_as_content_node({
    :allowed_child_content_types => %w(
      Image InternalLink ExternalLink
    ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_update  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box'],
    :has_own_content_box => true,
    :controller_name => 'links_boxes',
    :show_in_menu => false,
    :copyable => false
  })
end
