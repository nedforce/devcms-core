# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Section+ objects.
class Admin::SectionsController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +Page+ content node to.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +Section+ object to act upon.
  before_filter :find_section,                 :only => [ :show, :previous, :edit, :update ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]

  before_filter :find_images_and_attachments,  :only => [ :show, :previous ]

  before_filter :find_children,                :only => [ :show, :previous ]

  before_filter :set_commit_type,              :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /admin/sections/:id
  # * GET /admin/sections/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @section }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @section }
    end
  end

  # * GET /admin/sections/:id/previous
  # * GET /admin/sections/:id/previous.xml
  def previous
    @section = @section.previous_version
    show
  end

  # * GET /admin/sections/new
  def new
    @section = Section.new(params[:section])
    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @section }}
    end
  end

  # * GET /admin/sections/:id/edit
  def edit
    @show_frontpage_control = can_set_frontpage?
    @section.attributes     = params[:section]
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @section }}
    end
  end

  # * POST /admin/sections
  # * POST /admin/pages/sections.xml
  def create
    @section        = Section.new(params[:section])
    @section.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @section.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @section }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      elsif @commit_type == 'save' && @section.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @section }, :status => :unprocessable_entity }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
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
          render :template => 'admin/shared/update_preview', :locals => { :record => @section }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @section, :status => :created, :location => @section }
      elsif @commit_type == 'save' && @section.save(:user => current_user, :approval_required => @for_approval)
        format.html # update.html.erb
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @section }, :status => :unprocessable_entity }
        format.xml  { render :xml => @section.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Retrieves the requested +Section+ object using the passed in +id+ parameter.
  def find_section
    @section = Section.find(params[:id], :include => :node).current_version
  end

  def find_children
    @children = @section.accessible_children_for(current_user)
  end

  def can_set_frontpage?
    current_user_is_admin?(@section.node) || current_user_is_final_editor?(@section.node)
  end
end
