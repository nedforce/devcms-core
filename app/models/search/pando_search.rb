class Search::PandoSearch
  def self.search_url params = nil
    uri = URI.parse(DevcmsCore.config.pando_search_url)
    uri.query = params.to_param
    return uri
  end

  def self.search(query, page, page_size, user, top_node, options)
    query = { q: query, size: page_size, page: page}
    results = query_pando query
    if results.is_a?(Net::HTTPSuccess)
      parsed_results, total_results = parse_results results.body
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

  def self.parse_results results
    result_hash = JSON.parse(results)
    results = []
    searchResult   = Searcher::SEARCH_RESULT_STRUCT
    result_hash['hits'].each do |hit|
      res         = searchResult.new
      res.title   = hit['fields']['title']
      res.content = hit['fields']['body']
      res.url     = hit['url']
      results << res
    end
    total_results = result_hash['total']
    return results, total_results
  end

  def self.search_suggestions term
    uri = URI.parse(DevcmsCore.config.pando_suggest_url)
    uri.query = {q: term}.to_param

    req = Net::HTTP::Get.new(uri.to_s)
    res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }
    result = JSON.parse(res.body)
    result['suggestions'].map{|sug| sug['text']}
  end
end
