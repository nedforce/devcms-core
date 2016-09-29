# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Forum+ objects.
class Admin::ForumsController < Admin::AdminController
  # The +create+ action needs the parent +Node+ object to link the new +Forum+ content node to.
  prepend_before_action :find_parent_node, only: [:new, :create]

  # The +show+, +edit+ and +update+ actions need a +Forum+ object to act upon.
  before_action :find_forum, only: [:show, :edit, :update]

  before_action :find_forum_topics, only: :show

  before_action :set_commit_type, only: [:create, :update]

  layout false

  require_role ['admin'], except: :show

  # * GET /admin/forums/:id
  # * GET /admin/forums/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @forum }
    end
  end

  # * GET /admin/forums/new
  def new
    @forum = Forum.new(permitted_attributes)

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @forum } }
    end
  end

  # * GET /admin/forums/:id/edit
  def edit
    @forum.attributes = permitted_attributes
  end

  # * POST /admin/forums
  # * POST /admin/forums.xml
  def create
    @forum        = Forum.new(permitted_attributes)
    @forum.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @forum.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @forum }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      elsif @commit_type == 'save' && @forum.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @forum }, :status => :unprocessable_entity }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/forums/:id
  # * PUT /admin/forums/:id.xml
  def update
    @forum.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @forum.valid?
        format.html do
          find_forum_topics
          render :template => 'admin/shared/update_preview', :locals => { :record => @forum }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      elsif @commit_type == 'save' && @forum.save(:user => current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit, :status => :unprocessable_entity }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def permitted_attributes
    params.fetch(:forum, {}).permit!
  end

  # Finds the +Forum+ object corresponding to the passed in +id+ parameter.
  def find_forum
    @forum = Forum.includes(:node).find(params[:id]).current_version
  end

  def find_forum_topics
    @forum_topics = @forum.forum_topics.accessible
  end
end
