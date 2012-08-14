# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +ExternalLink+ objects.
class Admin::LinksController < Admin::AdminController

  # The +new+ and +create+ actions need the parent +Node+ object.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +edit+ and +update+ actions need a +ExternalLink+ object to act upon.
  before_filter         :find_link,  :only => [ :show, :edit, :update, :previous ]

  # Set the subclass of +Theme+ to create based on the parent node
  before_filter         :set_subclass,        :only => [ :new, :create, :edit, :update ]

  before_filter         :set_commit_type,     :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /external_links/:id
  # * GET /external_links/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @link }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @link }
    end
  end 

  # * GET /admin/links/:id/previous
  # * GET /admin/links/:id/previous.xml
  def previous
    @link = @link.previous_version
    show
  end

  # * GET /admin/links/new
  def new
    @link = @subclass.new
    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @link }}
    end
  end

  # * GET /admin/links/:id/edit
  def edit
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @link }}
    end
  end

  # * POST /admin/links
  # * POST /admin/links.xml
  def create
    @link = @subclass.new(params[@type])
    @link.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @link.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @link }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      elsif @commit_type == 'save' && @link.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @link }, :status => :unprocessable_entity }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/links/:id
  # * PUT /admin/links/:id.xml
  def update
    @link.attributes = params[@type]
    
    respond_to do |format|
      if @commit_type == 'preview' && @link.valid?
        format.html { render :template => 'admin/shared/update_preview', :locals => { :record => @link }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      elsif @commit_type == 'save' && @link.save(:user => current_user)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @link }, :status => :unprocessable_entity }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +ExternalLink+ object corresponding to the passed in +id+ parameter.
  def find_link
    @link = Link.find(params[:id], :include => :node).current_version
  end

  def set_subclass
    @type     = params[:type]
    @subclass = @type.classify.constantize
  end
end
