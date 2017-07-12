class PandoSearchController < ApplicationController

  caches_action :search_suggestions, cache_path: -> (_controller) { { term: @term } }

  def search_suggestions
    @results = []
    if @term = params[:term]
      @results = Search::PandoSearch.search_suggestions(@term)
    end

    render json: @results.to_json
  end
end
