class Admin::DataWarningsController < Admin::AdminController
  before_filter :set_paging,  :only => :index
  before_filter :set_sorting, :only => :index

  skip_before_filter :set_actions
  skip_before_filter :find_node

  require_role ['admin', 'final_editor'], :any_node => true

  layout false

  # * GET /admin/trash
  # * GET /admin/trash.json
  def index
    @active_page = :data_warnings

    @data_warnings_count = DataChecker::DataWarning.count
    @data_warnings = DataChecker::DataWarning.order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit)

    respond_to do |format|
      format.html { render :layout => 'admin' }
      format.json do
        data_warnings_for_json = @data_warnings.map do |warning|
          {
            :subject => (
              if warning.subject
                view_context.link_to_content_node(warning.subject.to_label, warning.subject, {}, target: :_blank)
              else
                '(Sindsdien verwijderd)'
              end
            ),
            :error_code => DataChecker::DataWarning.human_error_code(warning.error_code),
            :message => warning.message,
            :created_at => warning.created_at,
            :node_id => (warning.subject.node.id if warning.subject),
            :id => warning.id
          }
        end
        render :json => { :data_warnings => data_warnings_for_json, :total_count => @data_warnings_count }.to_json, :status => :ok
      end
    end
  end
  
  # * DELETE /admin/data_warnings/:id.json
  def destroy
    @data_warning = DataChecker::DataWarning.find(params[:id])

    respond_to do |format|
      if @data_warning.destroy
        format.json { head :ok }
      else
        format.json { render :json => I18n.t('data_warnings.destroy_failed'), :status => :unprocessable_entity }
      end
    end
  end

  # * DELETE /admin/data_warnings/:id/clear.json
  def clear
    success = DataChecker::DataWarning.delete_all rescue false

    respond_to do |format|
      if success
        format.json { head :ok }
      else
        format.json { render :json => I18n.t('data_warnings.clear_failed'), :status => :unprocessable_entity }
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
      @sort_direction = 'DESC'
      @sort_field = 'created_at'
    end
  end
end
