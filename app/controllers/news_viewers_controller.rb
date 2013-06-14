# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsViewer+ objects.
class NewsViewersController < ApplicationController

  # The +show+ action needs a +NewsViewer+ object to work with.
  before_filter :find_news_viewer, :only => [:show, :archive]
  
  # The +show+ action needs a list of recent news items to work with.
  before_filter :find_recent_news_items, :only => :show  

  # * GET /news_viewers/:id
  # * GET /news_viewers/:id.atom
  # * GET /news_viewers/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.any(:rss, :atom) { render :layout => false }
      format.xml  { render :xml => @news_viewer }
    end
  end

  # * GET /news_viewers/:id/archive
  # * GET /news_viewers/:id/:year/:month
  def archive
    @date        = Date.parse("#{params[:year]||params[:date][:year]}-#{params[:month]||params[:date][:month]}-1") rescue Date.today
    @news_items  = @news_viewer.accessible_news_items
    @start_date  = @news_items.minimum(:publication_start_date).to_date rescue Date.today
    @end_date    = @news_items.maximum(:publication_start_date).to_date rescue Date.today
    @valid_range = (@start_date.beginning_of_month..Date.today.end_of_month)
    @date        = Date.today unless @valid_range.cover? @date
    @news_items  = @news_items.where('nodes.publication_start_date' => @date.beginning_of_month..@date.end_of_month)

    respond_to do |format|
      format.html { render :template => '/news_archives/archive' }
    end
  end

protected

  # Finds the +NewsViewer+ object corresponding to the passed in +id+ parameter.
  def find_news_viewer
    @news_viewer = @node.content
  end

  # Finds recent news items.
  def find_recent_news_items
    max_news_items = @news_viewer.items_max || Settler[:news_items_max] || 25
    featured_news_items = @news_viewer.items_featured || Settler[:news_items_featured] || 5
    @news_items = @news_viewer.accessible_news_items.page(params[:page]).per(max_news_items).to_a
    @show_archives = @news_viewer.show_archives
    @latest_news_items = []

    if params[:page].blank? || params[:page].to_i == 1
      @latest_news_items = @news_items[0..featured_news_items-1] if featured_news_items > 0
      if @show_archives
        @news_items_for_table = @news_items[featured_news_items..@news_items.count-1]
      elsif featured_news_items < max_news_items
        @news_items_for_table = @news_items[featured_news_items..max_news_items-1]
      end
    end
  end
end
