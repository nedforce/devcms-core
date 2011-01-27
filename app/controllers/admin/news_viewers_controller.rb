class Admin::NewsViewersController < Admin::AdminController

   # The +create+ action needs the parent +Node+ object to link the new +NewsViewer+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +NewsViewer+ object to act upon.
  before_filter :find_news_viewer,         :only => [ :show, :edit, :edit_items, :update ]

  before_filter :find_recent_news_items,   :only => :show
  
  before_filter :set_commit_type,          :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor' ], :except => [ :show ]

  # * GET /news_viewers/:id
  # * GET /news_viewers/:id.xml
  def show
    @actions << { :url => { :action => :edit_items }, :text => I18n.t('news_viewers.edit_items'), :method => :get } if current_user.has_any_role?    
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @news_viewer }
    end
  end

  # * GET /admin/news_viewers/new
  def new
    @news_viewer = NewsViewer.new(params[:news_viewer])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :object => @news_viewer }}
    end
  end

  # * GET /admin/news_viewers/:id/edit
  def edit
    @news_viewer.attributes = params[:news_viewer]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :object => @news_viewer }}
    end
  end
  
  def edit_items
    @news_archives = NewsArchive.all(:include => :node, :conditions => @news_viewer.node.containing_site.descendant_conditions)
  end

  # * POST /admin/news_viewers
  # * POST /admin/news_viewers.xml
  def create
    @news_viewer        = NewsViewer.new(params[:news_viewer])
    @news_viewer.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @news_viewer.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :object => @news_viewer }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @news_viewer, :status => :created, :location => @news_viewer }
      elsif @commit_type == 'save' && @news_viewer.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @news_viewer, :status => :created, :location => @news_viewer }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :object => @news_viewer }, :status => :unprocessable_entity }
        format.xml  { render :xml => @news_viewer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/news_viewers/:id
  # * PUT /admin/news_viewers/:id.xml
  def update
    @news_viewer.attributes = params[:news_viewer]

    respond_to do |format|
      if @commit_type == 'preview' && @news_viewer.valid?
        format.html { render :template => 'admin/shared/update_preview', :locals => { :object => @news_viewer }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @news_viewer, :status => :created, :location => @news_viewer }
      elsif @commit_type == 'save' && @news_viewer.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :object => @news_viewer }, :status => :unprocessable_entity }
        format.xml  { render :xml => @news_viewer.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +NewsViewer+ object corresponding to the passed in +id+ parameter.
  def find_news_viewer
    @news_viewer = NewsViewer.find(params[:id], :include => [:node])
  end

  def find_recent_news_items
    @news_items            = @news_viewer.accessible_news_items_for(current_user, { :page => { :size => 25, :current => 1 }})
    @news_items_for_table  = @news_items.to_a
    @latest_news_items     = @news_items_for_table[0..7]
    @news_items_for_table -= @latest_news_items
  end  
end
