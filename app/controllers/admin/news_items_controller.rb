# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to NewsItem objects.
class Admin::NewsItemsController < Admin::AdminController
  # Only the +new+ and +create+ actions need a parent Node object.
  prepend_before_action :find_parent_node, only: [:new, :create]

  # The +new+ and +create+ actions need a NewsArchive object to act upon.
  before_action :find_news_archive, only: [:new, :create]

  # The +show+, +edit+ and +update+ actions need a NewsItem object to act upon.
  before_action :find_news_item, only: [:show, :edit, :update, :previous]

  # Parse the publication dates for the +create+ and +update+ actions.
  before_action :parse_publication_start_date, only: [:create, :update]
  before_action :parse_publication_end_date,   only: [:create, :update]

  before_action :find_images_and_attachments, only: [:show, :previous]

  before_action :set_commit_type, only: [:create, :update]

  layout false

  require_role ['admin', 'final_editor', 'editor']

  # * GET /admin/news_items/:id
  # * GET /admin/news_items/:id.xml
  def show
    @header_image = Image.accessible.includes(:node).where("nodes.ancestry = :latest_news_ancestry", latest_news_ancestry: @news_item.node.child_ancestry).first

    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @news_item }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @news_item }
    end
  end

  # * GET /admin/news_items/:id/previous
  # * GET /admin/news_items/:id/previous.xml
  def previous
    @news_item = @news_item.previous_version
    show
  end

  # * GET /admin/news_items/new
  def new
    @news_item = @news_archive.news_items.build(permitted_attributes)

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @news_item } }
    end
  end

  # * GET /admin/news_items/:id/edit
  def edit
    @news_item.attributes = permitted_attributes

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @news_item } }
    end
  end

  # * POST /admin/news_items
  # * POST /admin/news_items.xml
  def create
    @news_item        = @news_archive.news_items.build(permitted_attributes)
    @news_item.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @news_item.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @news_item }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      elsif @commit_type == 'save' && @news_item.save(:user => current_user)
        format.html # create.html.erb
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @news_item }, :status => :unprocessable_entity }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/news_items/:id
  # * PUT /admin/news_items/:id.xml
  def update
    @news_item.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @news_item.valid?
        format.html do
          find_images_and_attachments
          render :template => 'admin/shared/update_preview', :locals => { :record => @news_item }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      elsif @commit_type == 'save' && @news_item.save(:user => current_user, :approval_required => @for_approval)
        format.html do
          @refresh = true
          render 'admin/shared/update'
        end
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @news_item }, :status => :unprocessable_entity }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def permitted_attributes
    params.fetch(:news_item, {}).permit!
  end

  # Finds the NewsArchive object corresponding to the parent node's content.
  def find_news_archive
    @news_archive = @parent_node.content
  end

  # Finds the NewsItem object corresponding to the passed in +id+ parameter.
  def find_news_item
    @news_item = NewsItem.includes(:node).find(params[:id]).current_version
  end
end
