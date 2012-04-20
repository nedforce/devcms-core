# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +NewsArchive+ objects.
class NewsArchivesController < ApplicationController
  
  # The +show+ action needs a +NewsArchive+ object to work with.  
  before_filter :find_news_archive, :only => :show

  # The +show+ action needs a list of recent news items to work with.
  before_filter :find_recent_news_items, :only => :show
   
  # * GET /news_archives/1
  # * GET /news_archives/1.atom
  # * GET /news_archives/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.atom { render :layout => false }
      format.xml  { render :xml => @news_archive }
    end
  end
  
protected
  
  # Finds the +NewsArchive+ object corresponding to the passed in +id+ parameter.
  def find_news_archive
    @news_archive = @node.content
  end

  # Finds recent news items.
  def find_recent_news_items
    max_news_items = (Settler[:news_items_max] ? Settler[:news_items_max] : 25)
    featured_news_items = (Settler[:news_items_featured] ? Settler[:news_items_featured] : 5)
    @news_items = @news_archive.news_items.accessible.all(:page => {:size => max_news_items, :current => params[:page]})
    
    @latest_news_items = []
    @news_items_for_table = @news_items.to_a

    if params[:page].blank? || params[:page].to_i == 1
      @latest_news_items = @news_items_for_table[0..featured_news_items-1] if featured_news_items>0
      @news_items_for_table = @news_items_for_table[featured_news_items..max_news_items-1] if featured_news_items<max_news_items
    end
  end
  
end
