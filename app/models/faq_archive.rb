class FaqArchive < ActiveRecord::Base
  acts_as_content_node(
    allowed_child_content_types: %w( FaqTheme ),
    allowed_roles_for_create:    %w( admin ),
    allowed_roles_for_update:    %w( admin ),
    allowed_roles_for_destroy:   %w( admin ),
    copyable:                    false
  )

  def icon_filename
    'poll.png'
  end

  def sub_themes
    node.children.with_content_type('FaqTheme').accessible
  end
end
