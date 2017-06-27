# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsArchive+ objects.
class NewsArchivesController < ApplicationController

  # The +show+ action needs a +NewsArchive+ object to work with.
  before_filter :find_news_archive, :only => [:show, :archive]

  # See application controller
  before_filter :set_max_news_items, :only => [:show, :archive]

  # The +show+ action needs a list of recent news items to work with.
  before_filter :find_recent_news_items, :only => :show
  caches_action :archive, cache_path: lambda { |controller| { id: @node.id }}, expires_in: 12.hours

  # * GET /news_archives/:id
  # * GET /news_archives/:id.atom
  # * GET /news_archives/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.haml
      format.any(:rss, :atom) { render :layout => false }
      format.xml { render :xml => @news_archive }
    end
  end

  # * GET /news_archives/:id/archive
  # * GET /news_archives/:id/:year/:month
  def archive
    respond_to do |format|
      format.html do
        @date        = Date.parse("#{params[:year]||params[:date][:year]}-#{params[:month]||params[:date][:month]}-1") rescue Date.today
        @news_items  = @news_archive.news_items.accessible
        @start_date  = @news_items.minimum(:publication_start_date).to_date rescue Date.today
        @end_date    = @news_items.maximum(:publication_start_date).to_date rescue Date.today
        @valid_range = (@start_date.beginning_of_month..Date.today.end_of_month)
        @date        = Date.today unless @valid_range.cover? @date
        @news_items  = @news_items.where('nodes.publication_start_date' => @date.beginning_of_month..@date.end_of_month).page(params[:page]).per(@max_news_items)
        # archive.html.haml
      end
      format.xml do
        @news_items = @news_archive.news_items.where('nodes.publication_start_date < ?', Time.now)
        render file: 'news_archives/archive.pxml'
      end
      format.csv do
        render text: @news_archive.to_csv
      end
    end
  end

protected

  # Finds the +NewsArchive+ object corresponding to the passed in +id+ parameter.
  def find_news_archive
    @news_archive = @node.content
  end

  def set_max_news_items
    @max_news_items = @news_archive.items_max || Settler[:news_items_max] || 25
    @featured_news_items = @news_archive.items_featured || Settler[:news_items_featured] || 5
  end

  # Finds recent news items.
  def find_recent_news_items
    @news_items = @news_archive.news_items.accessible.page(params[:page]).per(@max_news_items).to_a
    @latest_news_items = []

    if params[:page].blank? || params[:page].to_i == 1
      @latest_news_items = @news_items[0..@featured_news_items-1] if @featured_news_items > 0
      @news_items_for_table = @news_items[@featured_news_items..@max_news_items-1] if @featured_news_items < @max_news_items
    end
  end
end
