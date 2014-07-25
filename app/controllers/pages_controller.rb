# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to Page objects.
class PagesController < ApplicationController
  before_filter :find_page,                   :only => :show
  before_filter :find_images_and_attachments, :only => :show
  
  # * GET /pages/:id
  # * GET /pages/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @page }
    end
  end
  
  def home
    render :layout => false
  end
  
protected
  
  # Finds the Page object corresponding to the passed in +id+ parameter.
  def find_page
    @page = @node.content
  end  
end
