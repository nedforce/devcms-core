# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Weblog+ objects.
class Admin::WeblogsController < Admin::AdminController
  before_action :default_format_json, only: :index

  # The +show+, +edit+ and +update+ actions need a +Weblog+ object to act upon.
  before_action :find_weblog,       only: [:show, :edit, :update]

  before_action :find_weblog_posts, only: :show

  before_action :set_commit_type,   only: :update

  layout false

  require_role %w(admin final_editor), except: [:index, :show]

  # * GET /admin/weblogs.json?node=1&active_node_id=2
  #
  # *parameters*
  #
  # +node+           - Id of the node of which the children are requested
  # +super_node+     - Id of the node of which the children are requested,
  #                    when also a year and/or month is specified.
  # +active_node_id+ - (Optional) Id of the active node. If the active node is
  #                    contained by this weblog, the containing year and month
  #                    will auto-expand.
  def index
    respond_to do |format|
      node_id      = params[:super_node] || params[:node]
      @weblog_node = Node.find(node_id)

      active_node                  = params[:active_node_id] ? Node.find(params[:active_node_id]) : nil
      archive_includes_active_node = active_node && @weblog_node.all_children.include?(active_node)

      parse_date_parameters

      format.json do
        if @year && @month
          @weblog_post_nodes = @weblog_node.content.find_all_items_for_month(@year, @month).map(&:node)
          render json: @weblog_post_nodes.map { |node| node.to_tree_node_for(current_user) }.to_json
        else
          common_hash = { treeLoaderName: Node.content_type_configuration('Weblog')[:tree_loader_name] }
          now         = Time.zone.now

          if @year
            @months = @weblog_node.content.find_months_with_items_for_year(@year).map do |m|
              active_node_date           = active_node.content.publication_start_date if archive_includes_active_node
              month_includes_active_node = archive_includes_active_node && (active_node_date.year == @year && active_node_date.month == m)
              {
                text:        Date::MONTHNAMES[m].capitalize,
                expanded:    month_includes_active_node || (!archive_includes_active_node && (@year == now.year && m == now.month)),
                extraParams: {
                  super_node: node_id,
                  year:       @year,
                  month:      m
                }
              }.reverse_merge(common_hash)
            end

            render json: @months.to_json
          else
            @years = @weblog_node.content.find_years_with_items.map do |y|
              year_includes_active_node = archive_includes_active_node ? (active_node.content.publication_start_date.year == y) : false
              {
                text:        y,
                expanded:    year_includes_active_node || (!archive_includes_active_node && (y == now.year)),
                extraParams: {
                  super_node: node_id,
                  year:       y
                }
              }.reverse_merge(common_hash)
            end

            render json: @years.to_json
          end
        end
      end
    end
  end

  # * GET /admin/weblogs/:id
  # * GET /admin/weblogs/:id.xml
  def show
    respond_to do |format|
      format.html { render partial: 'show', layout: 'admin/admin_show' }
      format.xml  { render xml: @weblog }
    end
  end

  # * GET /admin/weblogs/:id/edit
  def edit
    @weblog.attributes = permitted_attributes

    respond_to do |format|
      format.html { render template: 'admin/shared/edit', locals: { record: @weblog } }
    end
  end

  # * PUT /admin/weblogs/:id
  # * PUT /admin/weblogs/:id.xml
  def update
    @weblog.attributes = permitted_attributes

    respond_to do |format|
      if @commit_type == 'preview' && @weblog.valid?
        format.html do
          find_weblog_posts
          render template: 'admin/shared/update_preview', locals: { record: @weblog }, layout: 'admin/admin_preview'
        end
        format.xml  { render xml: @weblog, status: :created, location: @weblog }
      elsif @commit_type == 'save' && @weblog.save(user: current_user)
        format.html do
          @refresh = true
          render 'admin/shared/update'
        end
        format.xml  { head :ok }
      else
        format.html { render template: 'admin/shared/edit', locals: { record: @weblog }, status: :unprocessable_entity }
        format.xml  { render xml: @weblog.errors, status: :unprocessable_entity }
      end
    end
  end

  protected

  def permitted_attributes
    params.fetch(:weblog, {}).permit!
  end

  # Finds the +Weblog+ object corresponding to the passed in +id+ parameter.
  def find_weblog
    @weblog = Weblog.includes(:node).find(params[:id]).current_version
  end

  def find_weblog_posts
    @weblog_posts = @weblog.weblog_posts.accessible.includes(:node).order('weblog_posts.created_at DESC').page(1).per(25)

    @weblog_posts_for_table  = @weblog_posts.to_a
    @latest_weblog_posts     = @weblog_posts_for_table[0..5]
    @weblog_posts_for_table -= @latest_weblog_posts
  end
end
