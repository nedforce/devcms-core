# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +TopHitsPage+ objects.

class Admin::TopHitsPagesController < Admin::AdminController
  # The +create+ action needs the parent +Node+ object to link the new +TopHitsPage+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +TopHitsPage+ object to act upon.
  before_filter :find_top_hits_page,       :only => [ :show, :edit, :update ]

  before_filter :find_top_hits,            :only => [ :show ]

  before_filter :set_commit_type,          :only => [ :create, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :show ]

  # * GET /top_hits_pages/:id
  # * GET /top_hits_pages/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @top_hits_page }
    end
  end

  # * GET /admin/top_hits_pages/new
  def new
    @top_hits_page = TopHitsPage.new(permitted_attributes)

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @top_hits_page } }
    end
  end

  # * GET /admin/top_hits_pages/:id/edit
  def edit
    @top_hits_page.attributes = permitted_attributes

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @top_hits_page } }
    end
  end

  # * POST /admin/top_hits_pages
  # * POST /admin/top_hits_pages.xml
  def create
    @top_hits_page        = TopHitsPage.new(permitted_attributes)
    @top_hits_page.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @top_hits_page.valid?
        find_top_hits

        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @top_hits_page }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @top_hits_page, :status => :created, :location => @top_hits_page }
      elsif @commit_type == 'save' && @top_hits_page.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @top_hits_page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @top_hits_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/top_hits_pages/:id
  # * PUT /admin/top_hits_pages/:id.xml
  def update
    @top_hits_page.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @top_hits_page.valid?
        find_top_hits

        format.html { render :template => 'admin/shared/update_preview', :locals => { :record => @top_hits_page }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @top_hits_page, :status => :created, :location => @top_hits_page }
      elsif @commit_type == 'save' && @top_hits_page.save(:user => current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @top_hits_page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @top_hits_page.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def permitted_attributes
    params.fetch(:top_hits_page, {}).permit!
  end

  # Finds the +TopHitsPage+ object corresponding to the passed in +id+ parameter.
  def find_top_hits_page
    @top_hits_page = TopHitsPage.includes(:node).find(params[:id]).current_version
  end

  # Finds the top hits based on the +TopHitsPage+ object.
  def find_top_hits
    @top_hits = @top_hits_page.find_top_hits
  end
end
