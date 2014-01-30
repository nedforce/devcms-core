# This class is used to represent a search engine.
#
# Currently two engines are supported:
# * Ferret
# * Luminis
#
# NOTE: The Ferret search engine is capable of using synonyms;
#       see the +Synonym+ model for more info.
#
class Searcher
  if Devcms.search_configuration[:enabled_search_engines].include?('ferret')
    require 'acts_as_ferret'  
    
    # The supported search engines.
    ENGINES = [ 'ferret' ]

    # The structure of the result of a search.
    SEARCH_RESULT_STRUCT = Struct.new(:title, :tstamp, :content, :url, :node, :score, :highlighted_title, :highlighted_content)

    # Accessor to save the engine used.
    attr_accessor :engine

    # Initialize the +Searcher+. An engine can be specified; if none is specified, the
    # default search engine set in the configuration is used.
    def initialize(engine = Devcms.search_configuration[:default_search_engine])
      raise "Search engine unknown: #{engine.to_s}"  unless ENGINES.include?(engine)
      raise "Search engine disabled: #{engine.to_s}" unless Devcms.search_configuration[:enabled_search_engines].include?(engine)

      @engine = case engine
        when 'ferret'  then Search::FerretSearch
      end
    end

    # Execute a search on the given +query+ with the specified +options+.
    def search(query, options = {})
      # query = String.new(query)

      page      = options.delete(:page).to_i
      page      = page > 0 ? page : 1
      page_size = (options.delete(:page_size) || Devcms.search_configuration[:default_page_size]).to_i
      user      = options.delete(:for)
      top_node  = options.delete(:top_node)   || Node.root

      engine.search(query, page, page_size, user, top_node, options)
    end
  end
end

def Searcher(engine)
  Searcher.new(engine.to_s)
end
