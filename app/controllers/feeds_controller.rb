# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Feed+ objects.
class FeedsController < ApplicationController

  # The +show+, +edit+, +update+ and +destroy+ actions each need a +Feed+ object to work with/act on.  
  before_filter :find_feed, :only => :show

  # * GET /feeds/:id
  # * GET /feeds/:id.xml
  def show    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @feed }
    end
  end

protected

  # Finds the +Feed+ object corresponding to the passed in +id+ parameter.
  def find_feed
    @feed = @node.content
  end  
end
