# An external link is a content node that represents a link to an external location.
#
# *Specification*
#
# Attributes
#
# * +url+ - The external location that this external link links to.
#
# NOTE: For other attributes, see the +Link+ model.
#
# Preconditions
#
# * Requires the presence of +url+.
# * Requires +url+ to have a valid format.
#
class ExternalLink < Link
  
  # Adds content node functionality to links.
  acts_as_content_node({
    :available_content_representations => ['content_box'],
    :show_content_box_header => false,
    :controller_name => 'external_links'
  })
  
  needs_editor_approval
  
  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :url
  validates_format_of   :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.([a-z]{2,5}|[0-9]{1,5})(\/.*)?$)/ix

  # Overrides the +content_title+ method of the +acts_as_content_node+ mixin.
  def content_title
    self.title.blank? ? self.url : self.title
  end

  # Overwrite the default. In case the title is blank, strip the 'http://' part from the url.
  def path_for_url_alias(node)
    title.blank? ? (url.starts_with?('https://') ? url.gsub(/https:\/\//, '') : url.gsub(/http:\/\//, '')) : title
  end
end
