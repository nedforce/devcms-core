class Faq < ActiveRecord::Base
  acts_as_content_node({
    allowed_roles_for_create:    %w( admin final_editor editor ),
    allowed_roles_for_update:    %w( admin final_editor editor ),
    allowed_roles_for_destroy:   %w( admin final_editor editor ),
  })

  def icon_filename
    'poll_question.png'
  end
end
