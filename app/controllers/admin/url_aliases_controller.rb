class Admin::UrlAliasesController < Admin::AdminController
  before_filter :find_node,   only: [:update, :destroy]
  before_filter :set_paging,  only: [:index, :create]
  before_filter :set_sorting, only: [:index, :create]

  require_role %w(admin final_editor)

  def index
    @active_page = :url_aliases
    @nodes       = Node.unscoped { Node.where('custom_url_suffix IS NOT NULL').order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit) }
    @node_count  = Node.where('custom_url_suffix IS NOT NULL').count

    respond_to do |format|
      format.html
      format.xml  { render action: :index }
      format.json { render json: { nodes: @nodes } }
    end
  end

  def create
    # Delegate extJS sorting/paging to index
    if extjs_paging? || extjs_sorting?
      index
    else
      raise ActionController::RoutingError, 'url_aliases#create is only for sorting purposes!'
    end
  end

  def update
    respond_to do |format|
      if @node.update_attributes params[:node]
        format.html { redirect_to admin_url_aliases_path, notice: I18n.t('nodes.node_update_succesful') }
        format.json { head :ok }
      else
        format.html { head :unprocessable_entity }
        format.json { render json: @node.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @node.update_column(:custom_url_suffix, nil)
    @node.update_column(:custom_url_alias,  nil)

    head :ok
  end

  protected

  def find_node
    @node = Node.unscoped.find params[:id]
  end

  # Finds sorting parameters.
  def set_sorting
    if extjs_sorting?
      @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')
      @sort_field = ActiveRecord::Base.connection.quote_column_name(params[:sort])
    else
      @sort_field = 'custom_url_alias'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /(id|created_at)/
  end
end
