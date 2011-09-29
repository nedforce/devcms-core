# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to HtmlPage objects.
class HtmlPagesController < ApplicationController
  before_filter :find_html_page,              :only => :show
  before_filter :find_images_and_attachments, :only => :show
  
  # * GET /html_pages/1
  # * GET /html_pages/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @html_page }
    end
  end
  
protected
  
  # Finds the HtmlPage object corresponding to the passed in +id+ parameter.
  def find_html_page
    @html_page = @node.content
  end

end
