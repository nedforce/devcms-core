class Admin::TagsController < Admin::AdminController
  before_filter :default_format_json,  :only => :update
    
  before_filter :set_paging,  :only => :index
  before_filter :set_sorting, :only => :index

  skip_before_filter :set_actions
  skip_before_filter :find_node    

  require_role 'admin'

  layout false

  # * GET /admin/tags
  # * GET /admin/tags.json
  def index
    @active_page    = :tags
    @tags       = ActsAsTaggableOn::Tag.order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit)
    @tags_count = ActsAsTaggableOn::Tag.count

    respond_to do |format|
      format.html { render :layout => 'admin' }
      format.json do
        render :json => { :tags => @tags.map(&:attributes), :total_count => @tags_count }.to_json, :status => :ok
      end
    end
  end

  # * PUT /admin/tags/:id.json
  def update
    @tag = ActsAsTaggableOn::Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attribute(:name, params[:tag].try(:fetch, :name))
        format.json { head :ok }
      else
        format.json { render :json => @tag.errors.full_messages.join(', '), :status => :unprocessable_entity }
      end
    end
  end

  protected

  # Finds sorting parameters.
  def set_sorting
    if extjs_sorting?
      @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')
      @sort_field = ActiveRecord::Base.connection.quote_column_name(params[:sort])
    else
      @sort_field = 'name'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id/
  end
end