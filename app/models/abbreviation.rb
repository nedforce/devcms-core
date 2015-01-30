# The abbreviation model represents abbreviations that may occur in content. Whenever
# an abbreviation tag is inserted in the editor, the definition is taken from the
# corresponding abbreviation model. The use of abbreviation tags is important for
# accessibility reasons.
#
# *Specification*
#
# Attributes
#
#  * +id+
#  * +abbr+ - The abbreviation as it may occur in the content.
#  * +definition+ - The definition of said abbreviation.
#  * +created_at+ - Timestamp when the record was created.
#  * +updated_at+ - Timestamp when the record was last updated.
#
class Abbreviation < ActiveRecord::Base
  belongs_to :node

  # See the preconditions overview for an explanation of these validations.
  validates :node,       presence: true
  validates :abbr,       presence: true, length: { maximum: 255 }
  validates :definition, presence: true, length: { maximum: 255 }

  # Find a record by normalized (alphanumeric, lowercase) abbr.
  def self.search(abbr)
    abbr = abbr.downcase.gsub(/[^a-z0-9]/, '')
    self.all(conditions: ["REPLACE(LOWER(abbr), '.', '' ) = ?", abbr])
  end
end
