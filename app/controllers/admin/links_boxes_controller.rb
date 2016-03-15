# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +LinksBox+ objects.
class Admin::LinksBoxesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +LinksBox+ content node to.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +LinksBox+ object to act upon.
  before_filter :find_links_box,                :only => [ :show,  :previous, :edit, :update ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]

  before_filter :find_images_and_attachments,  :only => [ :show, :previous ]

  before_filter :find_children,                :only => [ :show, :previous ]

  before_filter :set_commit_type,              :only => [ :create, :update ]

  layout false

  require_role 'admin'

  # * GET /admin/links_boxes/:id
  # * GET /admin/links_boxes/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => '/admin/links_boxes/show', :locals => { :record => @links_box }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @links_box }
    end
  end

  # * GET /admin/links_boxes/:id/previous
  # * GET /admin/links_boxes/:id/previous.xml
  def previous
    @links_box = @links_box.previous_version
    show
  end

  # * GET /admin/links_boxes/new
  def new
    @links_box = LinksBox.new(permitted_attributes)
    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @links_box } }
    end
  end

  # * GET /admin/links_boxes/:id/edit
  def edit
    @links_box.attributes = permitted_attributes
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @links_box } }
    end
  end

  # * POST /admin/links_boxes
  # * POST /admin/links_boxes.xml
  def create
    @links_box        = LinksBox.new(permitted_attributes)
    @links_box.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @links_box.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @links_box }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @links_box, :status => :created, :location => @links_box }
      elsif @commit_type == 'save' && @links_box.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render :xml => @links_box, :status => :created, :location => @links_box }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @links_box }, :status => :unprocessable_entity }
        format.xml  { render :xml => @links_box.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/links_boxes/:id
  # * PUT /admin/links_boxes/:id.xml
  def update
    @links_box.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @links_box.valid?
        format.html do
          find_images_and_attachments
          find_children
          render :template => 'admin/shared/update_preview', :locals => { :record => @links_box }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @links_box, :status => :created, :location => @links_box }
      elsif @commit_type == 'save' && @links_box.save(:user => current_user, :approval_required => @for_approval)
        format.html { render '/admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @links_box }, :status => :unprocessable_entity }
        format.xml  { render :xml => @links_box.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def permitted_attributes
    params.fetch(:links_box, {}).permit!
  end

  # Retrieves the requested +LinksBox+ object using the passed in +id+ parameter.
  def find_links_box
    @links_box = LinksBox.includes(:node).find(params[:id])
  end

  def find_children
    @children = @links_box.node.children.accessible.is_public.exclude_content_types('Image').include_content.all.map { |n| n.content }
  end
end
