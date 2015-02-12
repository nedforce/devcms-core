class Admin::AbbreviationsController < Admin::AdminController
  before_filter :default_format_json, only: [:create, :update, :destroy]

  before_filter :set_paging,  only: [:index, :create]
  before_filter :set_sorting, only: [:index, :create]

  skip_before_filter :set_actions
  before_filter :find_node, only: [:index, :new, :create, :update, :destroy]

  require_role 'admin', except: :new

  layout false

  # * GET /admin/abbreviations
  # * GET /admin/abbreviations.json
  def index
    @abbreviations       = @node.abbreviations.order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit)
    @abbreviations_count = @node.abbreviations.size

    respond_to do |format|
      format.html # index.html.erb
      format.json do
        abbreviations = @abbreviations.map do |s|
          { abbr:       s.abbr,
            definition: s.definition,
            id:         s.id
          }
        end
        render json: { abbreviations: abbreviations, total_count: @abbreviations_count }.to_json, status: :ok
      end
    end
  end

  # Show a abbreviation selection form for TinyMCE
  # * GET /admin/abbreviations/new
  def new
    @abbr          = params[:abbr]
    @abbreviations = @node.abbreviations.search(params[:abbr])

    render layout: false
  end

  # * POST /admin/abbreviations
  def create
    @abbreviation = @node.abbreviations.new(params[:abbreviation])

    respond_to do |format|
      if @abbreviation.save
        format.json { render json: { success: 'true' } }
      else
        format.json { render json: @abbreviation.errors.full_messages.join(' '), status: :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/abbreviations/:id.json
  def update
    @abbreviation = @node.abbreviations.find(params[:id])

    respond_to do |format|
      if @abbreviation.update_attributes(params[:abbreviation])
        format.json { head :ok }
      else
        format.json { render json: @abbreviation.errors, status: :unprocessable_entity }
      end
    end
  end

  # Destroys a +Abbreviation+.
  # * DELETE /admin/abbreviations/:id.json
  def destroy
    s = @node.abbreviations.find(params[:id])
    s.destroy

    respond_to do |format|
      format.json { head :ok }
    end
  end

  protected

  def find_node
    @node = Node.find(params[:node_id])
  end

  # Finds sorting parameters.
  def set_sorting
    if extjs_sorting?
      @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')
      @sort_field = ActiveRecord::Base.connection.quote_column_name(params[:sort])
    else
      @sort_field = 'abbr'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id/
  end
end
