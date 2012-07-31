# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +ExternalLink+ objects.
class Admin::ExternalLinksController < Admin::AdminController

  # The +new+ and +create+ actions need the parent +Node+ object.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +edit+ and +update+ actions need a +ExternalLink+ object to act upon.
  before_filter         :find_external_link,        :only => [ :show, :edit, :update, :previous ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /external_external_links/:id
  # * GET /external_external_links/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @external_link }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @external_link }
    end
  end 

  # * GET /admin/external_links/:id/previous
  # * GET /admin/external_links/:id/previous.xml
  def previous
    @external_link = @external_link.previous_version
    show
  end

  # * GET /admin/external_links/new
  def new
    @external_link = ExternalLink.new
  end

  # * GET /admin/external_links/:id/edit
  def edit
  end

  # * POST /admin/external_links
  # * POST /admin/external_links.xml
  def create
    @external_link = ExternalLink.new(params[:external_link])
    @external_link.parent = @parent_node

    respond_to do |format|
      if @external_link.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @external_link, :status => :created, :location => @external_link }
      else
        format.html { render :action => :new, :status => :unprocessable_entity }
        format.xml  { render :xml => @external_link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/external_links/:id
  # * PUT /admin/external_links/:id.xml
  def update
    @external_link.attributes = params[:external_link]
    
    respond_to do |format|
      if @external_link.save(:user => current_user, :approval_required => @for_approval)       
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit, :status => :unprocessable_entity }
        format.xml  { render :xml => @external_link.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +ExternalLink+ object corresponding to the passed in +id+ parameter.
  def find_external_link
    @external_link = ExternalLink.find(params[:id], :include => :node).current_version
  end
end
