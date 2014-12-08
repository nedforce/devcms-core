class FaqTheme < Theme
  acts_as_content_node({
    allowed_child_content_types: %w( FaqCategory FaqTopFive ),
    allowed_roles_for_create:    %w( admin final_editor editor ),
    allowed_roles_for_update:    %w( admin final_editor editor ),
    allowed_roles_for_destroy:   %w( admin final_editor editor ),
    expiration_container:        true,
    controller_name:             'faq_themes'
  })

  def icon_filename
    'poll_question.png'
  end

end
