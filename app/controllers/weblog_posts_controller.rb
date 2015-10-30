# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Weblog+ objects. It offers special actions
# to allow registered users to create, update and delete their own weblogs.
class WeblogPostsController < ApplicationController
  # Require the user to be logged in for the +new+, +create+, +edit+, +update+,
  # +destroy+ and +destroy_image+ actions.
  before_filter :login_required, only: [:new, :create, :edit, :update, :destroy, :destroy_image]

  # The +new+, +create+, +edit+, +update+, +destroy+ and +destroy_image+ actions
  # need a parent +Weblog+ object to work with.
  before_filter :find_weblog, only: [:new, :create, :edit, :update, :destroy, :destroy_image]

  # The +show+, +edit+, +update+, +destroy+ and +destroy_image+ actions need a
  # +WeblogPost+ object to work with.
  before_filter :find_weblog_post, only: [:show, :edit, :update, :destroy, :destroy_image]

  # Check whether the user is authorized to perform the +new+, +create+, +edit+,
  # +update+, +destroy+ and +destroy_image+ actions.
  before_filter :check_authorization_for_weblog_post, only: [:new, :create, :edit, :update, :destroy, :destroy_image]

  before_filter :find_images_and_attachments, only: [:show, :edit]

  # The maximum number of images allowed in a post.
  MAX_IMAGES = 4

  # * GET /weblogs_posts/:id
  # * GET /weblogs_posts/:id.atom
  # * GET /weblogs_posts/:id.xml
  def show
    @images   = @image_content_nodes
    @comments = @weblog_post.node.comments.all(limit: 25, order: 'comments.created_at DESC')

    respond_to do |format|
      format.html # show.html.erb
      format.any(:rss, :atom) { render layout: false }
      format.xml { render xml: @weblog_post }
    end
  end

  # * GET /weblog_archives/1/weblogs/1/weblog_posts/new
  def new
    @page_title  = I18n.t('weblogs.create_weblog_post')
    @weblog_post = @weblog.weblog_posts.build
    @images      = []
  end

  # * GET /weblog_archives/1/weblogs/1/weblog_posts/edit
  def edit
    @images = @image_content_nodes
  end

  # * POST /weblog_archives/1/weblogs/1/weblog_posts
  # * POST /weblog_archives/1/weblogs/1/weblog_posts.xml
  def create
    @weblog_post        = @weblog.weblog_posts.build(params[:weblog_post])
    @weblog_post.parent = @weblog.node

    if params[:images]
      @images = params[:images].values.select { |image| image[:file].respond_to?(:original_filename) }
      images  = @images[0..MAX_IMAGES - 1].map { |image| Image.new(file: image[:file], title: image[:file].original_filename) }
    end

    respond_to do |format|
      if @weblog_post.save(user: current_user)
        images.delete_if do |image|
          image.parent = @weblog_post.node
          success = image.save(user: current_user)
          image.versions.current.approve! if success
          success
        end if images

        flash[:warn] = I18n.t('weblogs.not_all_images_saved') if images.present?

        format.html { redirect_to [@weblog.weblog_archive, @weblog] }
        format.xml  { render xml: @weblog_post, status: :created, location: @weblog_post }
      else
        format.html do
          @images = []
          render action: :new
        end
        format.xml { render xml: @weblog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # * PUT /weblog_archives/1/weblogs/1/weblog_posts/1
  # * PUT /weblog_archives/1/weblogs/1/weblog_posts/1.xml
  def update
    allowed_extra_images = MAX_IMAGES - @weblog_post.node.children.size

    if params[:images]
      @images = params[:images].values.select { |image| image[:file].respond_to?(:original_filename) }
      images = @images[0..allowed_extra_images - 1].map { |image| Image.new(parent: @weblog_post.node, file: image[:file], title: image[:file].original_filename) }
    end

    @weblog_post.attributes = params[:weblog_post]

    respond_to do |format|
      if @weblog_post.save(user: current_user)
        images.delete_if do |image|
          success = image.save(user: current_user)
          image.versions.current.approve! if success
          success
        end if images

        flash[:warning] = I18n.t('weblogs.not_all_images_saved') if images.present?

        format.html { redirect_to aliased_or_delegated_path(@weblog_post.node) }
        format.xml  { head :ok }
      else
        format.html do
          find_images_and_attachments
          @images = @image_content_nodes
          render action: :edit
        end
        format.xml { render xml: @weblog_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # * DELETE /weblog_archives/1/weblogs/1/weblog_posts/1
  # * DELETE /weblog_archives/1/weblogs/1/weblog_posts/1.xml
  def destroy
    @weblog_post.destroy

    respond_to do |format|
      format.html { redirect_to aliased_or_delegated_path(@weblog.node) }
      format.xml  { head :ok }
    end
  end

  # * DELETE /weblog_archives/1/weblogs/1/weblog_posts/1/destroy_image/1
  # * DELETE /weblog_archives/1/weblogs/1/weblog_posts/destroy_image/1/1.xml
  def destroy_image
    Image.find(params[:image_id]).destroy

    respond_to do |format|
      format.html { redirect_to aliased_or_delegated_path(@weblog_post.node) }
      format.js do
        render :update do |page|
          page.visual_effect :fade, "weblog_post_image_#{params[:image_id]}"
          page.insert_html :bottom, 'weblog_post_image_forms', "<p>#{file_field_tag 'images[][data]'}</p>" if params[:is_form]
          page.remove "weblog_post_image_#{params[:image_id]}"
        end
      end
      format.xml { head :ok }
    end
  end

  protected

  # Finds the +Weblog+ object corresponding to the passed in +weblog_id+
  # parameter.
  def find_weblog
    @weblog = Weblog.find(params[:weblog_id])
  end

  # Finds the +WeblogPost+ object corresponding to the passed in +id+ parameter.
  def find_weblog_post
    @weblog_post = @node.content
  end

  # Checks whether the user is authorized to perform the action.
  def check_authorization_for_weblog_post
    unless @weblog.is_owned_by_user?(current_user) || current_user.has_role?('admin')
      flash[:notice] = I18n.t('application.not_authorized')
      redirect_to root_path
    end
  end
end
