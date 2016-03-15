# This model is used to represent an alphabetic index. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the alphabetic index.
# * +content_type+ - The type of content this index should show
#
# Preconditions
#
# * Requires the presence of +title+.
#
class AlphabeticIndex < ActiveRecord::Base
  # Adds content node functionality to alphabetic indexes.
  acts_as_content_node({
    allowed_roles_for_update:  %w( admin ),
    allowed_roles_for_create:  %w( admin ),
    allowed_roles_for_destroy: %w( admin ),
    copyable:                  false
  })

  # See the preconditions overview for an explanation of these validations.
  validates :title,        presence: true, length: { maximum: 255 }
  validates :content_type, presence: true, inclusion: { in: DevcmsCore::Engine.config.allowed_content_types_for_alphabetic_index }

  # Returns an alphabetic list of all the descendant Items
  # of type ContentType of the parent.
  def items(letter = 'A')
    if letter.present?
      if content_type.present?
        klass = content_type.constantize
      else
        klass = Page
      end

      klass.accessible
        .includes(node: :base_tags)
        .reorder("CASE WHEN UPPER(#{klass.table_name}.title) LIKE UPPER('#{letter}%') THEN UPPER(#{klass.table_name}.title) ELSE UPPER(tags.name) END")
        .where(node.parent.descendant_conditions)
        .where("UPPER(#{klass.table_name}.title) LIKE UPPER(:expr) OR (taggings.context = 'title_alternatives' AND UPPER(tags.name) LIKE UPPER(:expr))", expr: "#{letter}%")
    end
  end
end
