class FaqTopFive < Theme
  acts_as_content_node({
    allowed_child_content_types: %w( ),
    allowed_roles_for_create:    %w( admin final_editor editor ),
    allowed_roles_for_update:    %w( admin final_editor editor ),
    allowed_roles_for_destroy:   %w( admin final_editor editor ),
    controller_name:             'faq_top_five'
  })

  def icon_filename
    'top_hits_page.png'
  end

  def content_children
    node.parent.descendants.with_content_type('Faq').accessible.order('hits DESC').limit(5)
  end

end
