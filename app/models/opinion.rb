# An +Opinion+ is a content node that represents an opportunity for users to
# give their opinion on a web page.
#
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# Preconditions
#
# Child/parent type constraints
#
class Opinion < ActiveRecord::Base
  # Adds content node functionality to opinions
  acts_as_content_node(
    available_content_representations: ['content_box'],
    allowed_child_content_types: %w( ),
    allowed_roles_for_create:    %w( admin final_editor editor ),
    allowed_roles_for_update:    %w( admin final_editor editor ),
    allowed_roles_for_destroy:   %w( admin final_editor editor ),
    controller_name: 'opinions',
    show_in_menu:    false,
    copyable:        false,
    has_own_content_box: true,
    has_default_representation: false,
  )

  has_many :opinion_entries, dependent: :destroy

  after_paranoid_delete :remove_associated_content

  def content_title
    title || default_title
  end

  def number_of_votes
    opinion_entries.count
  end

  def tree_text(_node)
    content_title
  end

  def vote(feeling, description, text)
    new OpinionEntry(opinion: self, feeling: feeling, description: description, text: text).save!
  end

  protected

  def remove_associated_content
    opinion_entries.destroy_all
  end
end
