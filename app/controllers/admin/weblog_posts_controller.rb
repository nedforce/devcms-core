# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +WeblogPost+ objects.
class Admin::WeblogPostsController < Admin::AdminController
  # The +show+, +edit+ and +update+ actions need a +WeblogPost+ object to act upon.
  before_action :find_weblog_post, only: [:show, :edit, :update]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_action :parse_publication_start_date, only: [:update]

  before_action :find_images_and_attachments, only: :show

  before_action :find_content, only: :show

  before_action :set_commit_type, only: :update

  layout false

  require_role %w(admin final_editor), except: :show

  # * GET /admin/weblog_posts/:id
  # * GET /admin/weblog_posts/:id.xml
  def show
    respond_to do |format|
      format.html { render partial: 'show', layout: 'admin/admin_show' }
      format.xml  { render xml: @weblog_post }
    end
  end

  # * GET /admin/weblog_posts/:id/edit
  def edit
    @weblog_post.attributes = permitted_attributes

    respond_to do |format|
      format.html { render template: 'admin/shared/edit', locals: { record: @weblog_post } }
    end
  end

  # * PUT /admin/weblog_posts/:id
  # * PUT /admin/weblog_posts/:id.xml
  def update
    @weblog_post.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @weblog_post.valid?
        format.html do
          find_images_and_attachments
          find_content
          render template: 'admin/shared/update_preview', locals: { record: @weblog_post }, layout: 'admin/admin_preview'
        end
        format.xml  { render xml: @weblog_post, status: :created, location: @weblog_post }
      elsif @commit_type == 'save' && @weblog_post.save(user: current_user)
        format.html do
          @refresh = true
          render 'admin/shared/update'
        end
        format.xml  { head :ok }
      else
        format.html { render template: 'admin/shared/edit', locals: { record: @weblog_post }, status: :unprocessable_entity }
        format.xml  { render xml: @weblog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def permitted_attributes
    params.fetch(:weblog_post, {}).permit!
  end

  # Finds the +WeblogPost+ object corresponding to the passed in +id+ parameter.
  def find_weblog_post
    @weblog_post = WeblogPost.includes(:node).find(params[:id]).current_version
  end

  def find_content
    @images   = @image_content_nodes
    @comments = @weblog_post.node.comments.limit(25).reorder(created_at: :desc)
  end
end
