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
    :allowed_roles_for_update  => %w( admin ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :copyable => false
  })

  ALLOWED_CONTENT_TYPES = %w( Page ResearchReport Product)

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of  :title, :content_type
  validates_length_of    :title, :in => 2..255, :allow_blank => true
  validates_inclusion_of :content_type, :in => ALLOWED_CONTENT_TYPES

  # Returns an alphabetic list of all the descendant Items of type ContentType of the parent.
  def items(letter = 'A', options = {})
    if letter.present?
      if self.content_type.present?
        klass = self.content_type.constantize
      else
        klass = Page
      end
      conditions = node.parent.descendant_conditions
      conditions = ["(#{conditions.shift})" + " AND (UPPER(#{klass.table_name}.title) LIKE UPPER(?) OR (taggings.context = 'title_alternatives' AND UPPER(tags.name) LIKE UPPER(?)))", conditions, "#{letter}%", "#{letter}%"].flatten
      klass.find_accessible(:all, { :include => { :node => :base_tags }, :order => "CASE WHEN UPPER(#{klass.table_name}.title) LIKE UPPER('#{letter}%') THEN UPPER(#{klass.table_name}.title) ELSE UPPER(tags.name) END", :conditions => conditions }.merge(options))
    end
  end
end
