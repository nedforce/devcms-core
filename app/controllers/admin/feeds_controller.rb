# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Feed+ objects.
class Admin::FeedsController < Admin::AdminController

  # The +new+ and +create+ actions need the parent +Node+ object.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +edit+ and +update+ actions need a +Feed+ object to act upon.
  before_filter :find_feed, :only => [ :show, :edit, :update ]

  layout false

  require_role [ 'admin' ]

  # * GET /admin/feeds/:id
  # * GET /admin/feeds/:id.xml
  def show
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @feed }
    end
  end

  # * GET /admin/feeds/new
  def new
    @feed = Feed.new

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @feed } }
    end
  end

  # * GET /admin/feeds/:id/edit
  def edit
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @feed } }
    end
  end

  # * POST /admin/feeds
  # * POST /admin/feeds.xml
  def create
    @feed = Feed.new(params[:feed])
    @feed.parent = @parent_node

    respond_to do |format|
      if @feed.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render :xml => @feed, :status => :created, :location => @feed }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @feed }, :status => :unprocessable_entity }
        format.xml  { render :xml => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/feeds/:id
  # * PUT /admin/feeds/:id.xml
  def update
    @feed.attributes = params[:feed]

    respond_to do |format|
      if @feed.save(:user => current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        @feed.reload # to retrieve the old title
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @feed }, :status => :unprocessable_entity }
        format.xml  { render :xml => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Feed+ object corresponding to the passed in +id+ parameter.
  def find_feed
    @feed = Feed.find(params[:id]).current_version
  end
end
