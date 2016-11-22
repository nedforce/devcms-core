class GoogleSiteSearchesController < ApplicationController
  PER_PAGE = 20

  before_action :find_term, only: :search_suggestions
  caches_action :search_suggestions, cache_path: -> (_controller) { { term: @term } }

  def show
    @query = params[:query]
    if @query.present?
      url = GoogleSiteSearch::UrlBuilder.new(
        @query,
        search_engine_identifier,
        start: start,
        num: PER_PAGE,
        filter: facet_filter
      )
      url = URI.parse(url.to_s)
      url.scheme = 'https'

      @search = GoogleSiteSearch::FacetSearch.new(url, GoogleSearchResult).query
      @results = @search.results.select(&:is_promotion?) + @search.results.reject(&:is_promotion?)
      @facets = @search.facets
    end

    @facets ||= []
    @results ||= []
  end

  def search_suggestions
    @results = []
    if @term
      @search_suggestions = GoogleSiteSearch::SearchSuggestions.new(
        @term, search_engine_identifier
      )
      @results = @search_suggestions.results
    end

    render json: @results.to_json
  end

  private

  def search_engine_identifier
    if current_site.content.google_search_engine.present?
      current_site.content.google_search_engine
    elsif Settler[:google_search_engine].present?
      Settler[:google_search_engine]
    end
  end

  def start
    (page - 1) * PER_PAGE
  end

  def page
    @page ||= [params[:page].to_i, 1].max
  end

  def facet_filter
    "more:#{params[:tab]}" if params[:tab].present?
  end

  def find_term
    @term = params[:term][0..1] if params[:term]
  end
end
