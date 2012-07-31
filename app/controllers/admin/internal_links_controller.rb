# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +InternalLink+ objects.
class Admin::InternalLinksController < Admin::AdminController

  # The +new+ and +create+ actions need the parent +Node+ object.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +edit+ and +update+ actions need a +InternalLink+ object to act upon.
  before_filter         :find_internal_link,        :only => [ :show, :edit, :update, :previous ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /internal_internal_links/:id
  # * GET /internal_internal_links/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @internal_link }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @internal_link }
    end
  end 

  # * GET /admin/internal_links/:id/previous
  # * GET /admin/internal_links/:id/previous.xml
  def previous
    @internal_link = @internal_link.previous_version
    show
  end

  # * GET /admin/internal_links/new
  def new
    @internal_link = InternalLink.new
  end

  # * GET /admin/internal_links/:id/edit
  def edit
  end

  # * POST /admin/internal_links
  # * POST /admin/internal_links.xml
  def create
    @internal_link = InternalLink.new(params[:internal_link])
    @internal_link.parent = @parent_node

    respond_to do |format|
      if @internal_link.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @internal_link, :status => :created, :location => @internal_link }
      else
        format.html { render :action => :new, :status => :unprocessable_entity }
        format.xml  { render :xml => @internal_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/internal_links/:id
  # * PUT /admin/internal_links/:id.xml
  def update
    @internal_link.attributes = params[:internal_link]
    
    respond_to do |format|
      if @internal_link.save(:user => current_user, :approval_required => @for_approval)       
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit, :status => :unprocessable_entity }
        format.xml  { render :xml => @internal_link.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +InternalLink+ object corresponding to the passed in +id+ parameter.
  def find_internal_link
    @internal_link = InternalLink.find(params[:id], :include => :node).current_version
  end
end
