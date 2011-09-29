# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Link+ objects.
class Admin::LinksController < Admin::AdminController

  # The +new+ and +create+ actions need the parent +Node+ object.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +edit+ and +update+ actions need a +Link+ object to act upon.
  before_filter         :find_link,        :only => [ :show, :edit, :update, :previous ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /links/:id
  # * GET /links/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @link }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @link }
    end
  end 

  # * GET /admin/link/:id/previous
  # * GET /admin/link/:id/previous.xml
  def previous
    @link = @link.previous_version
    show
  end

  # * GET /admin/links/new
  def new
    @link = ExternalLink.new
  end

  # * GET /admin/links/:id/edit
  def edit
  end

  # * POST /admin/links
  # * POST /admin/links.xml
  def create
    type = params[:link].delete(:type) rescue nil

    case type
      when "InternalLink"
        @link = InternalLink.new(params[:link])
      when "ExternalLink"
        @link = ExternalLink.new(params[:link])
      else
        @link = Link.new(params[:link])
    end
    @link.parent = @parent_node

    respond_to do |format|
      if @link.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        format.html { render :action => :new, :status => :unprocessable_entity }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/links/:id
  # * PUT /admin/links/:id.xml
  def update
    @link.attributes = params[:link]
    
    respond_to do |format|
      if @link.save(:user => current_user, :approval_required => @for_approval)       
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit, :status => :unprocessable_entity }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Link+ object corresponding to the passed in +id+ parameter.
  def find_link
    @link = Link.find(params[:id], :include => :node).current_version
  end
end
