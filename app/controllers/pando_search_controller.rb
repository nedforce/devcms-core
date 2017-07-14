class PandoSearchController < ApplicationController
  skip_before_filter :find_node
  before_filter :get_term
  
  caches_action :search_suggestions, cache_path: -> (_controller) { { term: @term } }

  def search_suggestions
    @results = []
    if @term
      @results = Search::PandoSearch.search_suggestions(@term)
    end

    render json: @results.to_json
  end

  protected
  def get_term
    @term = params[:term]
  end
end
