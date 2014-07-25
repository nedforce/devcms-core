# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to Carrousel objects.
class CarrouselsController < ApplicationController

  # * GET /carrousels/:id
  # * GET /carrousels/:id.xml
  def show
    @carrousel = @node.content
    
    if @carrousel.animation > 0
      @carrousel_items = @carrousel.items
    else
      @carrousel_item = @carrousel.current_item
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @carrousel }
    end
  end  
end
