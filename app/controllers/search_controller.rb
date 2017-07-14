class SearchController < ApplicationController
  skip_before_filter :find_node

  before_filter :set_search_engine
  before_filter :set_search_scope, :parse_search_scope

  def index
    @query = params[:query].try(:strip)

    @from = Date.parse(params[:from]) rescue nil
    @to   = Date.parse(params[:to])   rescue nil

    @advanced = params[:advanced]
    if @query
      @results = Searcher(@engine).search(@query, :page => params[:page], :for => current_user, :zipcode => params[:zipcode], :from => @from, :to => @to, :sort => params[:sort], :content_types_to_include => @content_types_to_include, :content_types_to_exclude => @content_types_to_exclude, :top_node => @top_node, :facets => params[:facets])
    else
      @results = []
    end
  end

protected

  def set_search_scope
    @search_scope = @search_scopes.find { |search_scope| search_scope.second == params[:search_scope] } || @search_scopes.first
  end

  def parse_search_scope
    @top_node = (@search_scope[1].present? ? Node.where(id: @search_scope[1].scan(/\d+/).first).first : nil)
  end

  def set_search_engine
    @engine = params[:search_engine] if params[:search_engine].present?
    @engine = Devcms.search_configuration[:default_search_engine] unless Devcms.search_configuration[:enabled_search_engines].include?(@engine)
  end
end
