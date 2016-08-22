# A mail link is a content node that represents a link to an email address.
#
# *Specification*
#
# Attributes
#
# * +email_address+ - The email address that this email link links to.
#
# NOTE: For other attributes, see the +Link+ model.
#
# Preconditions
#
# * Requires the presence of +email_address+.
# * Requires +email_address+ to have a valid format.
#
class MailLink < Link
  # Adds content node functionality to links.
  acts_as_content_node(
    available_content_representations: ['content_box'],
    show_content_box_header:           false,
    controller_name:                   'mail_links'
  )

  needs_editor_approval

  # See the preconditions overview for an explanation of these validations.
  validates :email_address, presence: true, email: { allow_blank: true }

  # Overrides the +content_title+ method of the +acts_as_content_node+ mixin.
  def content_title
    title.present? ? title : email_address
  end

  def mailto_link
    "mailto:#{email_address}"
  end

  # Overwrite the default.
  def path_for_url_alias(_node)
    title.present? ? title : email_address.tr('@', '-')
  end
end
