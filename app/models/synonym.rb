# This model is used to represent a synonym (a different name for
# a word). It is used when searching, so when someone searches on
# a word, its synonyms are taken into account. The synonyms are
# only used when Ferret is used as a search engine.
#
# *Specification*
#
# Attributes
#
# * +name+ - The synonym.
# * +original+ - The original word.
# * +weight+ - The weight of the synonym when searching.
#
# Preconditions
#
# * Requires the presence of +name+.
# * Requires the presence of +original+.
# * Requires the presence of +weight+.
# * Requires +weight+ to be a number.
# * Requires +name+ to be unique (case insensitive) for the original word.
#
class Synonym < ActiveRecord::Base
  # Synonyms are only used when Ferret is configured as the search engine.
  if SETTLER_LOADED && Devcms.search_configuration[:enabled_search_engines].is_a?(Array) && Devcms.search_configuration[:enabled_search_engines].include?('ferret')
    extend Search::Modules::Ferret::FerretSynonymExtension
    acts_as_searchable
  end

  belongs_to :node

  # See the preconditions overview for an explanation of these validations.
  validates :node,     presence: true
  validates :name,     presence: true, uniqueness: { scope: :original, case_sensitive: false }
  validates :original, presence: true
  validates :weight,   presence: true, numericality: { greater_than: 0 }
end
