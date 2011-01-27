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
      format.html { render :partial => '/admin/sections/show', :locals => { :record => @section }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @section }
    end
  end

  # * GET /admin/sites/:id/previous
  # * GET /admin/sites/:id/previous.xml
  def previous
    @section = @section.previous_version
    show
  end

  # * GET /admin/sites/new
  def new
    @section = Site.new(params[:section])
    render :template => '/admin/sections/new'
  end

  # * GET /admin/sites/:id/edit
  def edit
    @show_frontpage_control = can_set_frontpage?
    @section.attributes     = params[:section]
    render :template => '/admin/sections/edit'
  end

  # * POST /admin/sites
  # * POST /admin/sites.xml
  def create
    @section        = Site.new(params[:section])
    @section.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @section.valid?
        format.html { render :template => '/admin/sections/create_preview', :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      elsif @commit_type == 'save' && @section.save_for_user(current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :template => '/admin/sections/new' }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entitity }
      end
    end
  end
  
  # * PUT /admin/sections/:id
  # * PUT /admin/sections/:id.xml
  def update
    @show_frontpage_control = can_set_frontpage?
    params[:section].delete(:frontpage_node_id) if !@show_frontpage_control
    @section.attributes = params[:section]

    respond_to do |format|
      if @commit_type == 'preview' && @section.valid?
        format.html do
          find_images_and_attachments
          find_children
          render :template => '/admin/sections/update_preview', :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      elsif @commit_type == 'save' && @section.save_for_user(current_user, @for_approval)
        format.html { render :template => '/admin/sections/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => '/admin/sections/edit' }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entitity }
      end
    end
  end

protected

  # Retrieves the requested +Site+ object using the passed in +id+ parameter.
  def find_site
    @section = Site.find(params[:id], :include => :node)
  end

  def find_children
    @children = @section.accessible_children_for(current_user)
  end

  def can_set_frontpage?
    current_user_is_admin?(@section.node) || current_user_is_final_editor?(@section.node)
  end
end
