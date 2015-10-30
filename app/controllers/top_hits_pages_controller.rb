# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to TopHitsPage objects.
class TopHitsPagesController < ApplicationController
  before_filter :find_top_hits_page, only: :show

  # * GET /top_hits_pages/:id
  # * GET /top_hits_pages/:id.xml
  def show
    @top_hits = @top_hits_page.find_top_hits

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @top_hits_page }
    end
  end

  protected

  # Finds the TopHitsPage object corresponding to the passed in +id+ parameter.
  def find_top_hits_page
    @top_hits_page = @node.content
  end
end
