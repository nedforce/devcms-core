# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to ForumPost objects. It offers special actions
# to allow registered users to create, update and delete the posts they created.
class ForumPostsController < ApplicationController
  
  skip_before_filter :find_node

  # Require the user to be logged in for the +new+, +create+, +edit+, +update+ and +destroy+ actions.
  before_filter :login_required, :only => [ :new, :create, :edit, :update, :destroy ]

  # All actions need an ancestor Forum, ForumTopic and parent ForumThread object to work with.
  before_filter :find_forum_topic, :find_forum_thread, :only => [ :show, :new, :create, :edit, :update, :destroy ]

  # The +show+, +edit+, +update+ and +destroy+ actions need a ForumPost object to work with.
  before_filter :find_forum_post, :only => [ :show, :edit, :update, :destroy ]

  # Ensure the ForumPost object is not the start post of its ForumThread, for the +show+, +edit+, +update+ and +destroy+ actions.
  before_filter :ensure_forum_post_is_not_a_start_post, :only => [ :show, :edit, :update, :destroy ]

  # Check whether the user is authorized to perform the +edit+, +update+ and +destroy+ actions.
  before_filter :check_authorization, :only => [ :edit, :update, :destroy ]

  # * GET /forum_topics/1/forum_threads/1/forum_posts/1
  # * GET /forum_topics/1/forum_threads/1/forum_posts/1.xml
  def show
    respond_to do |format|
      format.html { redirect_to [ @forum_topic, @forum_thread ] }
      format.xml  { render :xml => @forum_post }
    end
  end

  # * GET /forum_topics/1/forum_threads/1/forum_posts/new
  def new
    @forum_post = @forum_thread.forum_posts.build
    @forum_post.user_name = current_user.login if logged_in?
  end

  # * GET /forum_topics/1/forum_threads/1/forum_posts/1/edit
  def edit
  end

  # * POST /forum_topics/1/forum_threads/1/forum_posts
  # * POST /forum_topics/1/forum_threads/1/forum_posts.xml
  def create
    @forum_post = @forum_thread.forum_posts.build(params[:forum_post])
    @forum_post.user = current_user

    respond_to do |format|
      if @forum_post.save
        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { render :xml => @forum_post, :status => :created, :location => @forum_post }
       else
        format.html { render :action => :new }
        format.xml  { render :xml => @forum_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /forum_topics/1/forum_threads/1/forum_posts/1
  # * PUT /forum_topics/1/forum_threads/1/forum_posts/1.xml
  def update
    respond_to do |format|
      if @forum_post.update_attributes(params[:forum_post])

        format.html { redirect_to [ @forum_topic, @forum_thread ] }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @forum_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * DELETE /forum_topics/1/forum_threads/1/forum_posts/1
  # * DELETE /forum_topics/1/forum_threads/1/forum_posts/1.xml
  def destroy
    @forum_post.destroy

    respond_to do |format|
      format.html { redirect_to [ @forum_topic, @forum_thread ] }
      format.xml  { head :ok }
    end
  end

protected

  # Finds the +ForumTopic+ object corresponding to the passed in +forum_topic_id+ parameter.
  def find_forum_topic
    @forum_topic = ForumTopic.find_accessible(params[:forum_topic_id], :for => current_user)
  end

  # Finds the +ForumThread+ object corresponding to the passed in +forum_thread_id+ parameter.
  def find_forum_thread
    @forum_thread = @forum_topic.forum_threads.find(params[:forum_thread_id])
  end

  # Finds the +ForumPost+ object corresponding to the passed in +id+ parameter.
  def find_forum_post
    @forum_post = @forum_thread.forum_posts.find(params[:id])
  end

  # Ensures that not attempt is made to view/edit or destroy a start post.
  def ensure_forum_post_is_not_a_start_post
    redirect_to [ @forum_topic, @forum_thread ] if @forum_post.is_start_post?
  end

  # Checks whether the user is authorized to perform the action.
  def check_authorization
    unless @forum_post.is_owned_by_user?(current_user) || current_user.has_role?('admin')
      flash[:notice] = I18n.t('application.not_authorized')
      redirect_to root_path
    end
  end

end

