# encoding: UTF-8

class Search::LuminisSearch
  
  def self.search(query, page, page_size, user, top_node, options)
    require 'rsolr'    
    
    solr = RSolr.connect :url => self.luminis_configuration[:solr_base_url]

    content_types_to_include = options.delete(:content_types_to_include)

    select_hash = {
      'hl.fragsize'    => 500, 
      'hl.simple.pre'  => '<span class="searchHighlight">', 
      'hl.simple.post' => '</span>', 
      :fl              => 'node, title, publicatieDatum, mutatieDatum, content, url, score', 
      :start           => (page-1)*page_size, 
      :rows            => page_size, 
      :wt              => options.delete(:wt) || :ruby 
    }

    if content_types_to_include.present?
      qt = content_types_to_include.map { |ct| { "productbeschrijving" => "product", "officiële publicatie" => "docs" }[ct.constantize.owms_type] || ct.constantize.owms_type }
      select_hash.merge!(:qt => qt.join(",")) 
    end

    zipcode = options.delete(:zipcode)
    select_hash[:fq]="_query_:\"{!wildcard f=locatiePostcode}#{ zipcode.gsub(' ','').upcase }\"" if zipcode.present?
    
    query ||= ''
    
    query = self.expand_query(query, top_node, options.delete(:from), options.delete(:to), options.delete(:programme), options.delete(:project), content_types_to_include, options.delete(:content_types_to_exclude))
    
    select_hash[:q] = query if query.present?
    
    select_hash.merge!(:sort => 'mutatieDatum desc') if options.delete(:sort) == 'date'

    Rails.logger.info "[#{Time.now.to_s}][LuminisSearcher] Running query: '#{query}'. Selecting: #{select_hash.pretty_inspect}."
    
    response = nil
    begin
      timeout(self.luminis_configuration[:solr_connection_timeout]) do
        response = solr.select(select_hash)
      end
    rescue Timeout::Error, RSolr::RequestError => e
      Rails.logger.warn "[#{Time.now.to_s}][LuminisSearcher] Error occurred while searching: '#{e}'"
      response = nil
    end

    numFound       = 0
    search_results = []
    if response && response['response'] && response['response']['docs'] && response['response']['numFound']
      numFound = response['response']['numFound']
      Rails.logger.info "[#{Time.now.to_s}][LuminisSearcher] Results found: #{numFound}."
      
      numFound = 250 if numFound > 250            
      maxScore = response['response']['maxScore'] || 1

      searchResult = Searcher::SEARCH_RESULT_STRUCT
      response['response']['docs'].each do |result|
        res         = searchResult.new
        res.title   = result['title'].is_a?(Array) ? title_from_array(result['title']) : result['title']
        res.tstamp  = DateTime.parse(result['mutatieDatum'].to_s) if result['mutatieDatum']
        res.content = result['content']
        res.url     = result['url']
        res.node    = Node.find(result['node']) if result['node'] rescue nil
        res.score   = (result['score'] || 0) / maxScore

        if response['highlighting'] && response['highlighting'][res.url]
          res.highlighted_title   = response['highlighting'][res.url]['title'].try(:first)
          res.highlighted_content = response['highlighting'][res.url]['content'].try(:first)
        end

        search_results << res
      end
    else
      Rails.logger.warn "[#{Time.now.to_s}][LuminisSearcher] Invalid SOLR response received: '#{response}'"
    end

    search_results.paginate(page, page_size, numFound)
  end

private

  def self.title_from_array(titles)
    titles.detect do |title| 
      !title.starts_with?('Lees verder') && 
      !title.starts_with?('Overheid.nl')
    end || titles[0]
  end

  def self.expand_query(query, top_node = nil, from = nil, to = nil, programme = nil, project = nil, content_types_to_include = nil, content_types_to_exclude = nil)
    query_parts = []
    if query.present?
      #explicitly search on the title and synonyms field
      query = "(content:(#{query}) OR title:(#{query})^#{self.luminis_configuration[:title_boost] || 1} OR synoniemen:(#{query})^#{self.luminis_configuration[:synonyms_boost] || 1})"
    
      # Date boost
      query = "{!boost b=recip(ms(NOW,mutatieDatum),#{1.to_f/((self.luminis_configuration[:date_boost] || 1.year).to_i*1000)},1,1)}#{query}"
      query_parts << query
    end

    # Top node filtering.
    query_parts << "ancestry:\"#{ top_node.id.to_s }\"" unless top_node.nil? || top_node.root?

    from = from.beginning_of_day.utc.to_s(:w3cdtfutc) if from
    to   = to.end_of_day.utc.to_s(:w3cdtfutc)         if to

    if from && to
      query_parts << "(publicatieDatum:[#{from} TO #{to}] OR mutatieDatum:[#{from} TO #{to}])"
    elsif from
      query_parts << "(publicatieDatum:[#{from} TO NOW] OR mutatieDatum:[#{from} TO NOW])"
    elsif to
      query_parts << "(publicatieDatum:[* TO #{to}] OR mutatieDatum:[* TO #{to}])"
    end

    if project.present?
      query_parts << "project:\"#{project}\""
    elsif programme.present?
      query_parts << "programma:\"#{programme}\""
    end
    
    query_parts.join " AND "
  end

  # Returns the Luminis configuration.
  def self.luminis_configuration
    config = Devcms.search_configuration[:luminis]
    Rails.logger.warn "[#{Time.now.to_s}][LuminisSearcher] No luminis configuration directives found in treehouse.rb! Should this module be enabled? Using default values instead..." if config.nil?
    config || { :date_boost => 1.year, :title_boost => 100, :synonyms_boost => 100, :solr_base_url => 'http://localhost/solr/', :solr_connection_timeout => 10 }
  end
end
