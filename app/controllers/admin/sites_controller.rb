# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Site+ objects.
class Admin::SitesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +Page+ content node to.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]
  
  # The +show+, +edit+ and +update+ actions need a +Site+ object to act upon.
  before_filter :find_site,                    :only => [ :show, :previous, :edit, :update ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]
  
  before_filter :find_images_and_attachments,  :only => [ :show, :previous ]

  before_filter :find_children,                :only => [ :show, :previous ]

  before_filter :set_commit_type,              :only => [ :create, :update ]

  layout false

  require_role 'admin'

  # * GET /admin/sites/:id
  # * GET /admin/sites/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => '/admin/sites/show', :locals => { :record => @site }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @site }
    end
  end

  # * GET /admin/sites/:id/previous
  # * GET /admin/sites/:id/previous.xml
  def previous
    @site = @site.previous_version
    show
  end

  # * GET /admin/sites/new
  def new
    @site = Site.new(params[:site])
    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @site }}
    end
  end

  # * GET /admin/sites/:id/edit
  def edit
    @show_frontpage_control = can_set_frontpage?
    @site.attributes     = params[:site]
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @site }}
    end
  end

  # * POST /admin/sites
  # * POST /admin/sites.xml
  def create
    @site        = Site.new(params[:site])
    @site.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @site.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @site }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      elsif @commit_type == 'save' && @site.save_for_user(current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @site }, :status => :unprocessable_entity }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entitity }
      end
    end
  end
  
  # * PUT /admin/sites/:id
  # * PUT /admin/sites/:id.xml
  def update
    @show_frontpage_control = can_set_frontpage?
    params[:site].delete(:frontpage_node_id) if !@show_frontpage_control
    @site.attributes = params[:site]

    respond_to do |format|
      if @commit_type == 'preview' && @site.valid?
        format.html do
          find_images_and_attachments
          find_children
          render :template => 'admin/shared/update_preview', :locals => { :record => @site }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      elsif @commit_type == 'save' && @site.save_for_user(current_user, @for_approval)
        format.html { render :template => '/admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @site }, :status => :unprocessable_entity }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entitity }
      end
    end
  end

protected

  # Retrieves the requested +Site+ object using the passed in +id+ parameter.
  def find_site
    @site = Site.find(params[:id], :include => :node)
  end

  def find_children
    @children = @site.accessible_children_for(current_user)
  end

  def can_set_frontpage?
    current_user_is_admin?(@site.node) || current_user_is_final_editor?(@site.node)
  end
end
