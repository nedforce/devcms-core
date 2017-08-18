class Search::PandoSearch
  def self.search_url params = nil
    uri = URI.parse(DevcmsCore.config.pando_search_url)
    uri.query = params.to_param
    return uri
  end

  def self.search(query, page, page_size, user, top_node, options)
    query = { q: query, size: page_size, page: page}
    query.merge!(facets: options[:facets]) if options[:facets]
    @pagination_params = {page: page, page_size: page_size}
    @results = query_pando query
    if @results.is_a?(Net::HTTPSuccess)
      result_hash = JSON.parse(@results.body)
      total_results = result_hash['total']
      parsed_results = parse_results result_hash
      parsed_results.paginate(page, page_size, total_results)
    end
  end

  def self.query_pando query
    url = search_url(query)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, :use_ssl => true) {|http|
      http.request(req)
    }
  end

  def self.parse_results result_hash
    results = []
    return results unless result_hash['hits'].present?
    searchResult   = Searcher::SEARCH_RESULT_STRUCT
    result_hash['hits'].each do |hit|
      res         = searchResult.new
      res.title   = hit['fields']['title']
      res.content = hit['fields']['body']
      res.url     = hit['url']
      results << res
    end
    return results
  end

  def self.available_facets
    return unless @results.is_a?(Net::HTTPSuccess)

    JSON.parse(@results.body)['facets']['category'].map{|facet| facet['key']}
  end

  def self.suggestion_results
    return nil, [], [] unless @results.is_a?(Net::HTTPSuccess)

    begin
      didyoumean = JSON.parse(@results.body)['suggestions']['didyoumean']
      total_results = didyoumean['result']['total']
      parsed_results = parse_results didyoumean['result']
      paginated_results = parsed_results.paginate(@pagination_params[:page], @pagination_params[:page_size], total_results)
      available_facets = didyoumean['result']['facets']['category'].map{|facet| facet['key']}

      return didyoumean['text'], paginated_results, available_facets
    rescue NoMethodError #Digging too deep into non-existing hashes
      return nil, [], []
    end
  end
end
