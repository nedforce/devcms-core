# This model is used to represent a search page. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the search page.
#
# Preconditions
#
# * Requires the presence of +title+.
#
class SearchPage < ActiveRecord::Base
  # Adds content node functionality to search_pages.
  acts_as_content_node({
    available_content_representations: ['content_box']
  })

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true

  # Returns the sidebox title for +SearchPage+.
  def self.sidebox_title
    I18n.t('search.search_in')
  end
end
