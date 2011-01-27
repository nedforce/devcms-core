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
  if DevCMS.search_configuration[:enabled_search_engines].include?('ferret')
    extend Search::Modules::Ferret::FerretSynonymExtension
    acts_as_searchable
  end

  belongs_to :node

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :node
  validates_presence_of     :name, :original, :weight
  validates_numericality_of :weight, :greater_than => 0
  validates_uniqueness_of   :name, :scope => :original, :case_sensitive => false
end
