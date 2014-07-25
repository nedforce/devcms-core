# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Page+ objects.
class Admin::PagesController < Admin::AdminController
  
  # The +create+ action needs the parent +Node+ object to link the new +Page+ content node to.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]
  
  # The +show+, +edit+ and +update+ actions need a +Page+ object to act upon.
  before_filter :find_page,                    :only => [ :show, :edit, :update, :previous ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]
  
  before_filter :find_images_and_attachments,  :only => [ :show, :previous ]

  before_filter :set_commit_type,              :only => [ :create, :update ]
  
  layout false
  
  require_role [ 'admin', 'final_editor', 'editor' ]
 
  # * GET /pages/:id
  # * GET /pages/:id.xml
  def show       
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @page }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @page }
    end
  end  

  # * GET /admin/page/:id/previous
  # * GET /admin/page/:id/previous.xml
  def previous
    @page = @page.previous_version
    show
  end
  
  # * GET /admin/pages/new
  def new
    @page = Page.new(params[:page])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @page }}
    end
  end
  
  # * GET /admin/pages/:id/edit
  def edit
    @page.attributes = params[:page]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @page }}
    end
  end

  # * POST /admin/pages
  # * POST /admin/pages.xml
  def create
    @page        = Page.new(params[:page])    
    @page.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @page.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @page }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      elsif @commit_type == 'save' && @page.save(:user => current_user)
        format.html # create.html.erb
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/pages/:id
  # * PUT /admin/pages/:id.xml
  def update
    @page.attributes = params[:page]

    respond_to do |format|
      if @commit_type == 'preview' && @page.valid?
        format.html do
          find_images_and_attachments
          render :template => 'admin/shared/update_preview', :locals => { :record => @page }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      elsif @commit_type == 'save' && @page.save(:user => current_user, :approval_required => @for_approval)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Page+ object corresponding to the passed in +id+ parameter.
  def find_page
    @page = Page.find(params[:id]).current_version
  end
end
