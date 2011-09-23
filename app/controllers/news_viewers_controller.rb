# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsViewer+ objects.
class NewsViewersController < ApplicationController

  # The +show+ action needs a +NewsViewer+ object to work with.
  before_filter :find_news_viewer, :only => :show
  
  # The +show+ action needs a list of recent news items to work with.
  before_filter :find_recent_news_items, :only => :show  

  # * GET /news_viewers/:id
  # * GET /news_viewers/:id.atom
  # * GET /news_viewers/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.atom { render :layout => false }
      format.xml  { render :xml => @news_viewer }
    end
  end

protected

  # Finds the +NewsViewer+ object corresponding to the passed in +id+ parameter.
  def find_news_viewer
    @news_viewer = @node.approved_content
  end

  # Finds recent news items.
  def find_recent_news_items
    @news_items = @news_viewer.accessible_news_items_for(current_user, { :page => { :size => 25, :current => params[:page] }})
    @latest_news_items = []
    @news_items_for_table = @news_items.to_a

    if params[:page].blank? || params[:page].to_i == 1
      @latest_news_items = @news_items_for_table[0..7]
      @news_items_for_table = @news_items_for_table[8..24]
    end
  end

end
