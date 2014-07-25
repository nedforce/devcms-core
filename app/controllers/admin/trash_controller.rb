class Admin::TrashController < Admin::AdminController
  before_filter :set_paging,  :only => :index
  before_filter :set_sorting, :only => :index

  skip_before_filter :set_actions
  skip_before_filter :find_node

  require_role ['admin', 'final_editor'], :any_node => true

  layout false

  # * GET /admin/trash
  # * GET /admin/trash.json
  def index
    @active_page = :trash

    @trash_items_count = Node.top_level_deleted_count
    @trash_items = Node.top_level_deleted(:all, { :order => "#{@sort_field} #{@sort_direction}", :page => { :size => @page_limit, :current => @current_page, :skip_scoping => true, :count => @trash_items_count } })

    respond_to do |format|
      format.html { render :layout => 'admin' }
      format.json do
        trash_items_for_json = @trash_items.map do |ti|
          {
            :title        => ti.title,
            :content_type => ti.sub_content_type,
            :path         => ti.ancestors_including_deleted.map(&:title).join(" / "),
            :deleted_at   => ti.deleted_at,
            :id           => ti.id
          }
        end
        render :json => { :trash_items => trash_items_for_json, :total_count => @trash_items_count }.to_json, :status => :ok
      end
    end
  end

  # * PUT /admin/trash/:id/restore.json
  def restore
    @trash_item = Node.top_level_deleted(:first, :conditions => { :id => params[:id] })

    success = @trash_item.paranoid_restore! rescue false

    respond_to do |format|
      if success
        format.json { head :ok }
      else
        format.json { render :json => I18n.t('trash.restore_failed'), :status => :unprocessable_entity }
      end
    end
  end

  # * DELETE /admin/trash/:id/clear.json
  def clear
    success = Node.delete_all_paranoid_deleted_content! rescue false

    respond_to do |format|
      if success
        format.json { head :ok }
      else
        format.json { render :json => I18n.t('trash.clear_failed'), :status => :unprocessable_entity }
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
      @sort_field = 'deleted_at'
    end
  end
end
