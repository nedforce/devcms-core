# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +WeblogPost+ objects.
class Admin::WeblogPostsController < Admin::AdminController

  # The +show+, +edit+ and +update+ actions need a +WeblogPost+ object to act upon.
  before_filter :find_weblog_post,             :only => [ :show, :edit, :update ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :update ]

  before_filter :find_images_and_attachments,  :only => :show

  before_filter :find_content,                 :only => :show

  before_filter :set_commit_type,              :only => :update

  layout false

  require_role [ 'admin', 'final_editor' ], :except => :show

  # * GET /admin/weblog_posts/:id
  # * GET /admin/weblog_posts/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @weblog_post }
    end
  end 

  # * GET /admin/weblog_posts/:id/edit
  def edit
    @weblog_post.attributes = params[:weblog_post]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @weblog_post }}
    end
  end

  # * PUT /admin/weblog_posts/:id
  # * PUT /admin/weblog_posts/:id.xml
  def update
    @weblog_post.attributes = params[:weblog_post]

    respond_to do |format|
      if @commit_type == 'preview' && @weblog_post.valid?
        format.html {
          find_images_and_attachments
          find_content
          render :template => 'admin/shared/update_preview', :locals => { :record => @weblog_post }, :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @weblog_post, :status => :created, :location => @weblog_post }
      elsif @commit_type == 'save' && @weblog_post.save
        format.html {
          @refresh = true
          render :template => 'admin/shared/update'
        }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @weblog_post }, :status => :unprocessable_entity }
        format.xml  { render :xml => @weblog_post.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +WeblogPost+ object corresponding to the passed in +id+ parameter.
  def find_weblog_post
    @weblog_post = WeblogPost.find(params[:id], :include => :node).current_version
  end

  def find_content
    @images   = @image_content_nodes
    @comments = @weblog_post.node.comments.all(:limit => 25, :order => 'comments.created_at DESC')
  end
end
