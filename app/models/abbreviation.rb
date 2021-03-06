# The abbreviation model represents abbreviations that may occur in content.
# Whenever an abbreviation tag is inserted in the editor, the definition is
# taken from the corresponding abbreviation model. The use of abbreviation tags
# is important for accessibility reasons.
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

  # Normalize (alphanumeric, lowercase) an abbr.
  def self.normalize(abbr)
    abbr.downcase.gsub(/[^a-z0-9]/, '')
  end

  # Find a record by normalized abbr.
  def self.search(abbr)
    where(["REPLACE(LOWER(abbr), '.', '') = ?", normalize(abbr)]).all
  end
end
