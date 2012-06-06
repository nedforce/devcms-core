# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +SearchPage+ objects.
class Admin::SearchPagesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +SearchPage+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +SearchPage+ object to act upon.
  before_filter :find_search_page,         :only => [ :show, :edit, :update ]

  layout false

  # * GET /admin/search_pages/:id
  # * GET /admin/search_pages/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @search_page }
    end
  end 

  # * GET /admin/search_pages/new
  def new
    @search_page = SearchPage.new(params[:search_page])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @search_page }}
    end
  end

  # * GET /admin/search_pages/:id/edit
  def edit
    @search_page.attributes = params[:search_page]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @search_page }}
    end
  end

  # * POST /admin/search_pages
  # * POST /admin/search_pages.xml
  def create
    @search_page = SearchPage.new(params[:search_page])
    @search_page.parent = @parent_node

    respond_to do |format|
      if @search_page.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @search_page, :status => :created, :location => @search_page }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @search_page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @search_page.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/search_pages/:id
  # * PUT /admin/search_pages/:id.xml
  def update
    @search_page.attributes = params[:search_page]

    respond_to do |format|
      if @search_page.save(:user => current_user)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @search_page }, :status => :unprocessable_entity }
        format.xml  { render :xml => @search_page.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
    end
  end

  protected

  # Finds the +SearchPage+ object corresponding to the passed in +id+ parameter.
  def find_search_page
    @search_page = SearchPage.find(params[:id], :include => :node).current_version
  end
end
