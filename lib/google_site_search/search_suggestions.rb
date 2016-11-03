module GoogleSiteSearch
  class SearchSuggestions
    URL = 'https://clients1.google.com/complete/search'
    DEFAULT_ARGUMENTS = {
      client: 'partner',
      ds: 'cse',
    }
    # A list with suggestions (string)
    attr_reader :results

    def initialize(query, search_engine_identifier, options = {})
      @query = query
      @search_engine_identifier = search_engine_identifier
      @options = options
      @results = []

      response = fetch_results

      if response.is_a? Net::HTTPOK
        parse_response(response.body)
      end
    end

    protected

    def fetch_results
      uri = URI.parse URL
      params = DEFAULT_ARGUMENTS.merge(
        partnerid: @search_engine_identifier,
        q: @query,
        cp: @query.size
      )

      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new(uri)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = @options[:timeout] if @options[:timeout]
      #http.set_debug_output(STDOUT) if Rails.env.development?

      http.request(request)
    end

    def parse_response(body)
      # Please see following file for a sample response:
      # fixtures/vcr_cassettes/google_search_suggestions.yml
      body = body.force_encoding("ISO-8859-1").encode("UTF-8")
      json_part = body.match(/\(.*\)/)[0] # Select the part between (...)
      json_part = json_part[1..-2] # Remove the (  )

      # An array with results
      result_list = JSON.parse(json_part)

      @results = result_list[1].map do |result|
        # Each result is a list where the first item is the suggestion word
        suggestion = result[0]

        # Some results are 'promotions'. In this case the 3th element in the
        # result is a hash with the following keys
        # a: promotion suggestion title
        # b: a url
        # c: unknown
        # d: a description
        is_promotion = (result.size == 3 && result[2].is_a?(Hash))

        # If the result is a promotion we return the promotion title as
        # suggestion. We ignore url and description
        if is_promotion && (promotion_suggestion = result[2]['a']).present?
          promotion_suggestion
        else
          suggestion
        end
      end
    end

  end
end
