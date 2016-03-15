# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Weblog+ objects. It offers special actions
# to allow registered users to create, update and delete their own weblogs.
class WeblogsController < ApplicationController
  # Require the user to be logged in for the +new+, +create+, +edit+, +update+
  # and +destroy+ actions.
  before_filter :login_required,          only: [:new, :create, :edit, :update, :destroy]

  # The +new+, +create+, +edit+, +update+ and +destroy+ actions need a parent +WeblogArchive+ object to work with.
  before_filter :find_weblog_archive,     only: [:new, :create, :edit, :update, :destroy]

  # Check whether the user hasn't yet got a weblog for the current weblog archive, for the +new+ and +create+ actions.
  before_filter :check_absence_of_weblog, only: [:new, :create]

  # The +show+, +edit+, +update+ and +destroy+ actions need a +Weblog+ object to work with.
  before_filter :find_weblog,             only: [:show, :edit, :update, :destroy]

  before_filter :find_weblog_posts,       only: :show

  # Check whether the user is authorized to perform the +edit+, +update+ and +destroy+ actions.
  before_filter :check_weblog_rights,     only: [:edit, :update, :destroy]

  # * GET /weblogs/:id
  # * GET /weblogs/:id.atom
  # * GET /weblogs/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.any(:rss, :atom) { render layout: false }
      format.xml { render xml: @weblog }
    end
  end

  # * GET /weblog_archives/:weblog_archive_id/weblogs/new
  def new
    @weblog = @weblog_archive.weblogs.build
  end

  # * GET /weblog_archives/:weblog_archive_id/weblogs/:id/edit
  def edit
  end

  # * POST /weblog_archives/:weblog_archive_id/weblogs
  # * POST /weblog_archives/:weblog_archive_id/weblogs.xml
  def create
    @weblog        = @weblog_archive.weblogs.build(permitted_attributes)
    @weblog.user   = current_user
    @weblog.parent = @weblog_archive.node

    respond_to do |format|
      if @weblog.save(user: current_user)
        format.html { redirect_to @weblog_archive }
        format.xml  { render xml: @weblog, status: :created, location: @weblog }
      else
        format.html { render action: :new }
        format.xml  { render xml: @weblog.errors, status: :unprocessable_entity }
      end
    end
  end

  # * PUT /weblog_archives/:weblog_archive_id/weblogs/:id
  # * PUT /weblog_archives/:weblog_archive_id/weblogs/:id.xml
  def update
    @weblog.attributes = permitted_attributes

    respond_to do |format|
      if @weblog.save(user: current_user)
        format.html { redirect_to aliased_or_delegated_path(@weblog.node) }
        format.xml  { head :ok }
      else
        format.html { render action: :edit }
        format.xml  { render xml: @weblog.errors, status: :unprocessable_entity }
      end
    end
  end

  # * DELETE /weblog_archives/:weblog_archive_id/weblogs/:id
  # * DELETE /weblog_archives/:weblog_archive_id/weblogs/:id.xml
  def destroy
    @weblog.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = I18n.t('weblogs.successfully_destroyed')
        redirect_to aliased_or_delegated_path(@weblog_archive.node)
      end
      format.xml { head :ok }
    end
  end

  protected

  def permitted_attributes
    params.fetch(:weblog, {}).permit!
  end

  # Finds the +WeblogArchive+ object corresponding to the passed in +weblog_archive_id+ parameter.
  def find_weblog_archive
    @weblog_archive = WeblogArchive.find(params[:weblog_archive_id])
  end

  # Finds the +Weblog+ object corresponding to the passed in +id+ parameter.
  def find_weblog
    @weblog = @node.content
  end

  def find_weblog_posts
    @weblog_posts = @weblog.weblog_posts.accessible.page(params[:page]).per(25)

    @latest_weblog_posts    = []
    @weblog_posts_for_table = @weblog_posts.to_a

    if !params[:page] || params[:page] == '1'
      @latest_weblog_posts     = @weblog_posts_for_table[0..5]
      @weblog_posts_for_table -= @latest_weblog_posts
    end
  end

  # Checks whether the user is authorized to perform the action.
  def check_weblog_rights
    unless @weblog.is_owned_by_user?(current_user) || current_user.has_role?('admin')
      flash[:notice] = I18n.t('application.not_authorized')
      redirect_to root_path
    end
  end

  # Checks whether the user hasn't yet got a weblog for the current weblog archive.
  def check_absence_of_weblog
    if @weblog_archive.has_weblog_for_user?(current_user)
      flash[:notice] = I18n.t('weblogs.weblog_already_present')
      redirect_to aliased_or_delegated_path(@weblog_archive.node)
    end
  end
end
