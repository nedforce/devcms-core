# This class is a custom Ferret stemming analyzer that is optimized for Dutch.
# It uses the Dutch Snowball stemmer and the list of Dutch stop words by default.
class DutchStemmingAnalyzer < Ferret::Analysis::Analyzer
  include Ferret::Analysis
  
  # Initialize the stemmer, using the Dutch stop words by default.
  #
  # *Parameters*
  #
  # +stop_words+ - An array of stop words.
  def initialize(stop_words = FULL_DUTCH_STOP_WORDS)
    @stop_words = stop_words
  end
  
  # Stem a stream of tokens by converting them to lowercase and using the Dutch
  # Snowball stemmer plus the list of stop words that the stemmer has been
  # initialized with.
  #
  # *Parameters*
  #
  # +field+ - Unused.
  # +str+ - The string to be stemmed.
  def token_stream(field, str)
    StemFilter.new(StopFilter.new(LowerCaseFilter.new(StandardTokenizer.new(str)), @stop_words), 'dut')
  end
end
