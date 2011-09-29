# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +HtmlPage+ objects.
class Admin::HtmlPagesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +HtmlPage+ content node to.
  prepend_before_filter :find_parent_node,    :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +HtmlPage+ object to act upon.
  before_filter :find_html_page,              :only => [ :show, :edit, :update ]

  before_filter :find_images_and_attachments, :only => [ :show ]

  before_filter :set_commit_type,             :only => [ :create, :update ]

  layout false

  # Only admins are allowed to create and manipulate HTML pages
  require_role [ 'admin' ], :except => :show

  # * GET /html_pages/:id
  # * GET /html_pages/:id.xml
  def show       
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @html_page }
    end
  end  

  # * GET /admin/html_pages/new
  def new
    @html_page = HtmlPage.new(params[:html_page])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @html_page }}
    end
  end

  # * GET /admin/html_pages/:id/edit
  def edit
    @html_page.attributes = params[:html_page]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @html_page }}
    end
  end

  # * POST /admin/html_pages
  # * POST /admin/html_pages.xml
  def create
    @html_page        = HtmlPage.new(params[:html_page])
    @html_page.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @html_page.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @html_page }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @html_page, :status => :created, :location => @html_page }
      elsif @commit_type == 'save' && @html_page.save
        format.html # create.html.erb
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @html_page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @html_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/html_pages/:id
  # * PUT /admin/html_pages/:id.xml
  def update
    @html_page.attributes = params[:html_page]

    respond_to do |format|
      if @commit_type == 'preview' && @html_page.valid?
        format.html {
          find_images_and_attachments
          render :template => 'admin/shared/update_preview', :locals => { :record => @html_page }, :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @html_page, :status => :created, :location => @html_page }
      elsif @commit_type == 'save' && @html_page.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @html_page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @html_page.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +HtmlPage+ object corresponding to the passed in +id+ parameter.
  def find_html_page
    @html_page = HtmlPage.find(params[:id]).current_version
  end

  # Disable the 'bewerken' button
  def set_actions
    @actions = []
  end
end
