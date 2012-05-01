class Search::FerretSearch

  def self.search(query, page, page_size, user, top_node, options)    
    search_tokens = []
    query.split.each do |token|
      # Default to fuzzy search unless an operator or wildcard were specified.
      unless token =~ /^(AND|NOT|OR|[\?\*~"])$/i
        search_tokens << self.create_search_string(token)
      else
        # Search operators must be in uppercase or they won't work properly.
        search_tokens << token.upcase
      end
    end

    query = "(#{search_tokens.join(' ')})"
    query = self.expand_query(query, top_node, options.delete(:zipcode), options.delete(:from), options.delete(:to), options.delete(:programme), options.delete(:project), options.delete(:content_types_to_include), options.delete(:content_types_to_exclude))
    pp query
    options = {:sort => Ferret::Search::SortField.new(:updated_at_to_index, :reverse => true) }.merge(options) if options.delete(:sort) == 'date'
    self.paginating_ferret_search({ :q => query, :page_size => page_size, :current => page, :limit => 250 }.merge(options))
  end

private

  # Adapted from http://www.igvita.com/2007/02/20/ferret-pagination-in-rails/
  def self.paginating_ferret_search(options)
    count  = Node.find_with_ferret(options[:q], { :lazy => true }).total_hits
    count  = options[:limit] if options[:limit] && options[:limit] < count
    offset = (options[:current].to_i - 1) * options[:page_size]

    search_results = []
    searchResult   = Searcher::SEARCH_RESULT_STRUCT
    count, hits    = Node.find_ids_with_ferret(options[:q], { :offset => offset, :limit => options[:page_size], :sort => options[:sort] })
    hits.each do |hit|
      node        = Node.find(hit[:id])
      res         = searchResult.new
      res.title   = node.content_title_to_index
      res.tstamp  = node.content.updated_at
      res.content = node.content_tokens_to_index
      res.node    = node
      res.score   = hit[:score]
      search_results << res
   end

   search_results.paginate(options[:current], options[:page_size], count)   
  end

  # Takes an existing search string and expands it with related words from the thesaurus.
  def self.create_search_string(token)
    synonym_tokens = []

    is_wildcard_search = token =~ /\*/
    count, hits = Synonym.find_ids_with_ferret(is_wildcard_search ? token : "#{token}~#{self.ferret_configuration[:proximity]}")
    hits.each do |hit|
      synonym = Synonym.find(hit[:id].to_i)
      word    = (synonym.name == token ? synonym.original : synonym.name)
      boost   = (hit[:score]**2)*self.ferret_configuration[:synonym_weight] #calculate the boost value using a non-linear function
      synonym_tokens << "(#{word}~#{self.ferret_configuration[:proximity]})^#{boost}" unless word == token
    end

    search_string = is_wildcard_search ? token : "(#{token}~#{self.ferret_configuration[:proximity]}"
    search_string << " OR #{synonym_tokens.join(' OR ')}" unless synonym_tokens.compact.empty?
    search_string << ")"
    search_string
  end

  def self.expand_query(query, top_node = nil, zipcode = nil, from = nil, to = nil, programme = nil, project = nil, content_types_to_include = nil, content_types_to_exclude = nil)
    now  = DateTime.now.strftime(Node::INDEX_DATETIME_FORMAT)
    from =         from.strftime(Node::INDEX_DATETIME_FORMAT) if from.present?
    to   =           to.strftime(Node::INDEX_DATETIME_FORMAT) if to.present?

    query << " AND (" + content_types_to_include.map { |ct| "content_type:#{ct}" }.join(' OR ') + ')' if content_types_to_include
    query << " AND (" + content_types_to_exclude.map { |ct| "NOT content_type:#{ct}" }.join(' AND ') + ')' if content_types_to_exclude
    query << " AND (publication_start_date_to_index: <= #{now})"
    query << " AND (publication_end_date_to_index: >= #{now} OR publication_end_date_to_index:none)"
    query << " AND (ancestry_to_index:XX#{top_node.child_ancestry.gsub(/\//, 'X')}X*)" unless top_node.root?
    query << " AND is_hidden_to_index:false"
    query << " AND categories_to_index:*X#{project}X*"   if project.present?   && programme.present?
    query << " AND categories_to_index:*X#{programme}X*" if programme.present? && project.blank?
    query << " AND zipcodes_to_index:*#{zipcode}*"       if zipcode.present?

    if from && to
      query << " AND (publication_start_date_to_index:[#{from} #{to}] OR updated_at_to_index:[#{from} #{to}])"
    elsif from
      query << " AND (publication_start_date_to_index:[#{from} #{now}] OR updated_at_to_index:[#{from} NOW])"
    elsif to
      query << " AND (publication_start_date_to_index:[* #{to}] OR updated_at_to_index:[* #{to}])"
    end
    
    # if user.is_a?(User)
    #   user.role_assignments.each do |ra|
    #     query << " OR ancestry_to_index:XX#{ra.node.child_ancestry}X*"
    #   end
    # end
    # query << ")"

    query
  end

  # Returns the Ferret configuration.
  def self.ferret_configuration
    config = Devcms.search_configuration[:ferret]
    Rails.logger.warn "[#{Time.now.to_s}][FerretSearcher] No ferret configuration directives found in treehouse.rb! Should this module be enabled? Using default values instead..." if config.nil?
    config || { :synonym_weight => 0.25, :proximity => 0.8 }
  end
end
