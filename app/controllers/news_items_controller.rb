# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to NewsItem objects.
class NewsItemsController < ApplicationController
  
  # The +show+ action needs a NewsItem object to work with.  
  before_filter :find_news_item, :only => :show
  before_filter :find_images_and_attachments, :only => :show
  
  # * GET /news_items/1
  # * GET /news_items/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @news_item }
    end
  end
  
protected
  
  # Finds the +NewsItem+ object corresponding to the passed in +id+ parameter.
  def find_news_item
    @news_item = NewsItem.find_accessible(
                              @node.content_id, 
                              :include => [ :node, { :node => :comments } ],
                              :for => current_user
                            )
  end
  
end
