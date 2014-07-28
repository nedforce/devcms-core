# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +ForumTopic+ objects.
class Admin::ForumTopicsController < Admin::AdminController

  # The +show+, +new+, +edit+, +update+ and +create+ actions need a parent +Node+ object.
  prepend_before_filter :find_parent_node,   :only => [ :new, :create ]

  # The +show+, +edit+, +create+ and +update+ actions need a +Forum+ object to act upon.
  before_filter         :find_forum,         :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +ForumTopic+ object to act upon.
  before_filter         :find_forum_topic,   :only => [ :show, :edit, :update ]

  before_filter         :find_forum_threads, :only => :show

  before_filter         :set_commit_type,    :only => [ :create, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :index, :show ]

  # * GET /admin/forum_topics/:id
  # * GET /admin/forum_topics/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @forum_topic }
    end
  end 

  # * GET /admin/forum_topics/new
  def new
    @forum_topic = @forum.forum_topics.build(params[:forum_topic])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @forum_topic } }
    end
  end

  # * GET /admin/forum_topics/:id/edit
  def edit
    @forum_topic.attributes = params[:forum_topic]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @forum_topic } }
    end
  end

  # * POST /admin/forum_topics
  # * POST /admin/forum_topics.xml
  def create
    @forum_topic        = @forum.forum_topics.build(params[:forum_topic])
    @forum_topic.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @forum_topic.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @forum_topic }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @forum_topic, :status => :created, :location => @forum_topic }
      elsif @commit_type == 'save' && @forum_topic.save(:user => current_user)
        format.html { render 'admin/shared/create' }
        format.xml  { render :xml => @forum_topic, :status => :created, :location => @forum_topic }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @forum_topic }, :status => :unprocessable_entity }
        format.xml  { render :xml => @forum_topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/forum_topics/:id
  # * PUT /admin/forum_topics/:id.xml
  def update
    @forum_topic.attributes = params[:forum_topic]

    respond_to do |format|
      if @commit_type == 'preview' && @forum_topic.valid?
        format.html do
          find_forum_threads
          render :template => 'admin/shared/update_preview', :locals => { :record => @forum_topic }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @forum_topic, :status => :created, :location => @forum_topic }
      elsif @commit_type == 'save' && @forum_topic.save(:user => current_user)
        format.html { render 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @forum_topic }, :status => :unprocessable_entity }
        format.xml  { render :xml => @forum_topic.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Forum+ object corresponding to the parent node's content.
  def find_forum
    @forum = @parent_node.content
  end

  # Finds the +ForumTopic+ object corresponding to the passed in +id+ parameter.
  def find_forum_topic
    @forum_topic = ((@forum) ? @forum.forum_topics : ForumTopic).find(params[:id], :include => :node).current_version
  end

  def find_forum_threads
    @forum_threads = @forum_topic.forum_threads_by_last_update_date.page(1).per(25)
  end
end
