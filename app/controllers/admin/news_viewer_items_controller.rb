class Admin::NewsViewerItemsController < Admin::AdminController
  skip_before_filter :find_node

  prepend_before_filter :find_news_viewer_and_node

  before_filter :find_news_archive, :only => :available_news_items

  layout false

  require_role ['admin', 'final_editor']

  def index
    @items = @news_viewer.news_viewer_items.all(:include => :news_item, :order => :position)

    respond_to do |format|
      format.json { render :json => @items.to_json(:include => { :news_item => { :only => 'title' } }) }
    end
  end

  def available_news_items
    respond_to do |format|
      format.html
      format.xml do
        set_paging

        @news_items                 = @news_viewer.news_items
        @available_news_items_count = @news_archive.news_items.newest.count
        @available_news_items       = @news_archive.news_items.newest.all :include => :node, :order => 'nodes.publication_start_date DESC', :limit => @page_limit, :offset => @page_limit*(@current_page-1)
      end
    end
  end

  def create
    @news_viewer_item = @news_viewer.news_viewer_items.find_or_initialize_by_news_item_id(NewsItem.find(params[:news_item_id]).id)
    respond_to do |format|
      if @news_viewer_item.save
        format.xml { render :nothing => true, :status => :created }
      else
        format.xml { render :nothing => true, :status => :unprocessable_entity }
      end
    end
  end

  def delete_news_item
    @item = @news_viewer.news_viewer_items.first(:conditions => { :news_item_id => params[:news_item_id] })
    respond_to do |format|
      if @item.nil? or @item.destroy
        format.xml { head :ok }
      else
        format.xml { render :nothing => true, :status => :unprocessable_entity }
      end
    end
  end

  def update_positions
    # Use update_all to skip callbacks
    params[:items].each_with_index{ |id, index| NewsViewerItem.update_all({ :position => index }, { :id => id }) } if params[:items].present?

    render :nothing => true, :status => 200
  end

private

  def find_news_archive
    @news_archive = NewsArchive.find(params[:news_archive_id])
  end

  def find_news_viewer_and_node
    @news_viewer = NewsViewer.find(params[:news_viewer_id])
    @node        = @news_viewer.node
  end
end
