# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +ForumThread+ objects. It offers special actions
# to allow registered users to create, update and delete the threads they started.
# Furthermore, this controller allows admins to open and close threads.
class ForumThreadsController < ApplicationController

  skip_before_filter :find_node
    
  # Require the user to be logged in for the +open+, +close+, +new+, +create+, +edit+, +update+ and +destroy+ actions.
  before_filter :login_required, :only => [ :open, :close, :new, :create, :edit, :update, :destroy ]
  
  # Only an administrator may perform the +open+ and +close+ actions.
  require_role [ 'admin' ], :only => [ :open, :close ]

  # The +show+, +edit+ actions needs the +ForumThread+ object to have a first post.
  prepend_before_filter :find_start_post, :only => [ :show, :edit ]

  # The +open+, +close+, +show+, +edit+, +update+ and +destroy+ actions need a +ForumThread+ object to work with.  
  prepend_before_filter :find_forum_thread, :only => [ :open, :close, :show, :edit, :update, :destroy ]
  
   # All actions need a parent +ForumTopic+ object to work with.  
  prepend_before_filter :find_forum_topic, :only => [ :open, :close, :show, :new, :create, :edit, :update, :destroy ]
  
  # Check whether the user is authorized to perform the +edit+, +update+ and +destroy+ actions.
  before_filter :check_authorization, :only => [ :edit, :update, :destroy ]
  
  # * GET /forum_topics/1/forum_threads/1
  # * GET /forum_topics/1/forum_threads/1.atom
  # * GET /forum_topics/1/forum_threads/1.xml
  def show
    # TODO: prefetching!
    @replies    = @forum_thread.replies
    @page_title = @forum_thread.title

    respond_to do |format|
      format.html # show.html.erb
      format.atom { render :layout => false }
      format.xml  { render :xml => @forum_thread }
    end
  end
  
  # * GET /forum_topics/1/forum_threads/new
  def new
    @forum_thread = @forum_topic.forum_threads.build
    @start_post   = @forum_thread.forum_posts.build
  end
  
  # * GET /forum_topics/1/forum_threads/1/edit
  def edit
    
  end
  
  # * POST /forum_topics/1/forum_threads
  # * POST /forum_topics/1/forum_threads.xml
  def create
    # Ugly code required because of DB2 gem handling nested transactions well differently.
    @forum_thread      = ForumThread.new(params[:forum_thread])
    @forum_thread.user = current_user
    @forum_thread.valid?

    @start_post      = ForumPost.new(params[:start_post])
    @start_post.user = current_user
    @start_post.valid?
    
    @forum_thread_valid = @forum_thread.errors.size == 2 && @forum_thread.errors.on(:forum_topic) && @forum_thread.errors.on(:forum_topic_id)
    @start_post_valid   = @start_post.errors.size   == 2 && @start_post.errors.on(:forum_thread)  && @start_post.errors.on(:forum_thread_id)
    
    if @forum_thread_valid && @start_post_valid
      ActiveRecord::Base.transaction do
        @forum_topic.forum_threads << @forum_thread
        @forum_thread.forum_posts  << @start_post
      end
    end
        
    # Suppress association errors, as they aren't particularly user-friendly.
    unless @forum_thread.errors.empty?
      errors = @forum_thread.errors.instance_variable_get(:@errors)
      errors.delete('forum_topic')
      errors.delete('forum_topic_id')
      @forum_thread.errors.instance_variable_set(:@errors, errors)
    end
    
    # Suppress association errors, as they aren't particularly user-friendly.
    unless @start_post.errors.empty?
      errors = @start_post.errors.instance_variable_get(:@errors)
      errors.delete('forum_thread')
      errors.delete('forum_thread_id')
      @start_post.errors.instance_variable_set(:@errors, errors)
    end
       
    respond_to do |format|
      if @forum_thread_valid && @start_post_valid
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { render :xml => @forum_thread, :status => :created, :location => @forum_thread }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @forum_thread.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # * PUT /forum_topics/1/forum_threads/1
  # * PUT /forum_topics/1/forum_threads/1.xml
  def update
    # Ugly code required because of DB2 gem handling nested transactions differently.
    @start_post = @forum_thread.start_post
    
    @forum_thread.attributes = params[:forum_thread]
    @forum_thread_valid = @forum_thread.valid?

    @start_post.attributes = params[:start_post]
    @start_post_valid = @start_post.valid?
    
    if @forum_thread_valid && @start_post_valid
      ForumThread.transaction do
        @forum_thread.save
        @start_post.save
      end
    end
       
    respond_to do |format|
      if @forum_thread_valid && @start_post_valid
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @forum_thread.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # * DELETE /forum_topics/1/forum_threads/1
  # * DELETE /forum_topics/1/forum_threads/1.xml
  def destroy
    # Scoped delete not possible due to bug in DB2 adapter.
    @forum_thread.destroy
    
    respond_to do |format|
      format.html { redirect_to aliased_or_delegated_path(@forum_topic.node) }
      format.xml  { head :ok }
    end
  end

  # * PUT /forum_topics/1/forum_threads/1/open
  # * PUT /forum_topics/1/forum_threads/1/open.xml
  def open
    respond_to do |format|      
      if @forum_thread.open
        flash[:notice] = I18n.t('forums.open_successfull')
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { head :ok }
      else
        flash[:warning] = I18n.t('forums.open_unsuccessfull')
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { render :xml => { :error => I18n.t('forums.open_unsuccessfull') } }
      end
    end
  end

  # * PUT /forum_topics/1/forum_threads/:id/close
  # * PUT /forum_topics/1/forum_threads/:id/close.xml
  def close
    respond_to do |format|      
      if @forum_thread.close
        flash[:notice] = I18n.t('forums.close_successfull')
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { head :ok }
      else
        flash[:warning] = I18n.t('forums.close_unsuccessfull')
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { render :xml => { :error => I18n.t('forums.close_unsuccessfull') } }
      end
    end
  end

  protected

    # Finds the +ForumTopic+ object corresponding to the passed in +forum_topic_id+ parameter.
    def find_forum_topic
      @forum_topic = ForumTopic.find_accessible(params[:forum_topic_id], :include => [ :node ], :for => current_user)
    end

    # Finds the +ForumThread+ object corresponding to the passed in +id+ parameter.
    def find_forum_thread
      @forum_thread = @forum_topic.forum_threads.find(params[:id], :include => [:forum_posts])
    end

    def find_start_post
      @start_post = @forum_thread.forum_posts.first
      raise ActiveRecord::RecordNotFound if @start_post.nil?
    end

    # Checks whether the user is authorized to perform the action.
    def check_authorization
      unless @forum_thread.is_owned_by_user?(current_user) || current_user.has_role?('admin')
        flash[:notice] = I18n.t('application.not_authorized')
        redirect_to root_path
      end
    end

    def set_rss_feed_url
      @rss_feed_url = forum_topic_forum_thread_url(@forum_topic,  @forum_thread, :format => 'atom')
    end
end
