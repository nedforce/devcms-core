# A html page is a content node that contains static text. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the page.
# * +body+ - The body of the page.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +body+.
#
# Child/parent type constraints
#
#  * A +HtmlPage+ only accepts +Attachment+ and +Image+ nodes.
#  * A +HtmlPage+ can be inserted into nodes of any accepting type.
#
class HtmlPage < ActiveRecord::Base
  # Adds content node functionality to html pages.
  acts_as_content_node({
    :allowed_child_content_types       => %w( Attachment AttachmentTheme Image Opinion ),
    :available_content_representations => ['content_box'],
    :allowed_roles_for_update          => %w( admin ),
    :allowed_roles_for_create          => %w( admin ),
    :allowed_roles_for_destroy         => %w( admin )
  })

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }
  validates :body,  presence: true

  # Returns the body as the tokens for indexing.
  def content_tokens
    body
  end

  # Returns the image file name to be used for icons on the front-end website.
  def icon_filename
    'page.png'
  end
end
