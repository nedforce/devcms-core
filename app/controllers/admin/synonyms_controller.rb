class Admin::SynonymsController < Admin::AdminController
  before_filter :default_format_json,  :only => [ :create, :update, :destroy ]  
    
  before_filter :set_paging,  :only => [ :index, :create ]
  before_filter :set_sorting, :only => [ :index, :create ]

  skip_before_filter :set_actions
  before_filter :find_node,   :only => [ :index, :create, :update, :destroy ]

  require_role 'admin'

  layout false

  # * GET /admin/synonyms
  # * GET /admin/synonyms.json
  def index
    @synonyms       = @node.synonyms.order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit)
    @synonyms_count = @node.synonyms.size

    respond_to do |format|
      format.html
      format.json do
        synonyms = @synonyms.map do |s|
          { :original => s.original,
            :name     => s.name,
            :weight   => s.weight,   
            :id       => s.id
          }
        end
        render :json => { :synonyms => synonyms, :total_count => @synonyms_count }.to_json, :status => :ok
      end
    end
  end

  # * POST /admin/synonyms
  def create
    @synonym = @node.synonyms.new(params[:synonym])

    respond_to do |format|
      if @synonym.save
        format.json { render :json => { :success => 'true' } }
      else
        format.json { render :json => @synonym.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/synonyms/:id.json
  def update
    @synonym = @node.synonyms.find(params[:id])

    respond_to do |format|
      if @synonym.update_attributes(params[:synonym])
        format.json { head :ok }
      else
        format.json { render :json => @synonym.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Destroys a +Synonym+.
  # * DELETE /admin/synonyms/1.json
  def destroy
    s = @node.synonyms.find(params[:id])
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
      @sort_field = 'original'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id|weight/
  end
end
