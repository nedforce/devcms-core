class SearchPagesController < ApplicationController

  def show
    redirect_to search_url(params.except(:id, :action, :controller).merge(:search_scope => "node_#{@node.parent.id}"))
  end
end

