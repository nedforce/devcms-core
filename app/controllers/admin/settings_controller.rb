class Admin::SettingsController < Admin::AdminController
  before_filter :default_format_json, only: :update

  before_filter :set_paging,  only: :index
  before_filter :set_sorting, only: :index

  skip_before_filter :set_actions
  skip_before_filter :find_node

  require_role 'admin'

  layout false

  # * GET /admin/settings
  # * GET /admin/settings.json
  def index
    @active_page    = :settings
    @settings       = Setting.where(editable: true).order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit)
    @settings_count = Setting.where(editable: true).count

    respond_to do |format|
      format.html { render layout: 'admin' }
      format.json do
        settings = @settings.map do |s|
          {
            key:   s.key,
            alt:   s.alt,
            value: s.type == 'password' ? '********' : s.value,
            type:  s.type,
            id:    s.id
          }
        end
        render json: { settings: settings, total_count: @settings_count }.to_json, status: :ok
      end
    end
  end

  # * PUT /admin/settings/:id.json
  def update
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update_attributes(value: params[:setting].try(:fetch, :value))
        format.json { head :ok }
      else
        format.json { render json: @setting.errors.full_messages.join(', '), status: :unprocessable_entity }
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
      @sort_field = 'key'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id/
  end
end
