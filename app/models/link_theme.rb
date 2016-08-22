class LinkTheme < Theme
  acts_as_content_node(
    allowed_child_content_types: %w(LinkTheme InternalLink ExternalLink MailLink),
    allowed_roles_for_create:    %w(admin final_editor editor),
    allowed_roles_for_update:    %w(admin final_editor editor),
    allowed_roles_for_destroy:   %w(admin final_editor editor),
    controller_name:             'link_themes'
  )
end
