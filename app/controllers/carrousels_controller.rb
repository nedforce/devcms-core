# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to NewsItem objects.
class CarrouselsController < ApplicationController

  # * GET /carrousels/:id
  # * GET /carrousels/:id.xml
  def show
    @carrousel      = @node.approved_content
    @carrousel_item = @carrousel.current_item

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @carrousel }
    end
  end  
end
