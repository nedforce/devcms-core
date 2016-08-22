# A LinksBox is a content node that represents a collection of Links.
class LinksBox < ActiveRecord::Base
  acts_as_content_node(
    allowed_child_content_types:       %w(LinkTheme Image InternalLink ExternalLink MailLink),
    allowed_roles_for_create:          %w(admin),
    allowed_roles_for_update:          %w(admin),
    allowed_roles_for_destroy:         %w(admin),
    available_content_representations: ['content_box'],
    has_own_content_box:               false,
    controller_name:                   'links_boxes',
    show_in_menu:                      false,
    copyable:                          false
  )

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }

  # Returns the last update date
  def last_updated_at
    ([node.self_and_children.accessible.maximum('nodes.updated_at')] + node.children.with_content_type('InternalLink').map { |link_node| link_node.content.linked_node.updated_at }).compact.max
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  def sub_themes
    node.children.with_content_type('LinkTheme').accessible
  end

  def content_children
    node.children.exclude_content_types(%w(Image LinkTheme)).accessible
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end
end
