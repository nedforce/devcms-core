# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Forum+ objects.
class Admin::ForumsController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +Forum+ content node to.
  prepend_before_filter :find_parent_node,  :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +Forum+ object to act upon.
  before_filter         :find_forum,        :only => [ :show, :edit, :update ]

  before_filter         :find_forum_topics, :only => :show

  before_filter         :set_commit_type,   :only => [ :create, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :show ]

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
    @forum = Forum.new(params[:forum])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :object => @forum }}
    end
  end

  # * GET /admin/forums/:id/edit
  def edit
    @forum.attributes = params[:forum]
  end

  # * POST /admin/forums
  # * POST /admin/forums.xml
  def create
    @forum        = Forum.new(params[:forum])
    @forum.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @forum.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :object => @forum }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      elsif @commit_type == 'save' && @forum.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :object => @forum }, :status => :unprocessable_entity }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/forums/:id
  # * PUT /admin/forums/:id.xml
  def update
    @forum.attributes = params[:forum]

    respond_to do |format|
      if @commit_type == 'preview' && @forum.valid?
        format.html {
          find_forum_topics
          render :template => 'admin/shared/update_preview', :locals => { :object => @forum }, :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @forum, :status => :created, :location => @forum }
      elsif @commit_type == 'save' && @forum.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Forum+ object corresponding to the passed in +id+ parameter.
  def find_forum
    @forum = Forum.find(params[:id], :include => [:node])
  end

  def find_forum_topics
    @forum_topics = @forum.forum_topics.find_accessible(:all, :for => current_user)
  end
end