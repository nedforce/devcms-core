# This administrative controller is used to manage role assignments (permissions).
class Admin::RoleAssignmentsController < Admin::AdminController
  before_filter :set_paging,  :only => [:index, :create]
  before_filter :set_sorting, :only => [:index, :create]

  require_role 'admin'

  layout false

  # * GET /admin/permissions
  # * GET /admin/permissions.json
  def index
    @active_page = :permissions

    # Sort the polymorphic node relationship separately if necessary.
    if !@sort_by_node
      @role_assignments = RoleAssignment.all(:include => [:user, :node], :order => "#{@sort_field} #{@sort_direction}", :page => { :size => @page_limit, :current => @current_page })
    else
      @role_assignments = RoleAssignment.all(:include => [:node, :user], :order => "users.login #{@sort_direction}")
      @role_assignments = @role_assignments.sort_by { |role_assignment| role_assignment.node.content.content_title.upcase }
      @role_assignments = @role_assignments.reverse if @sort_direction == 'DESC'
      @role_assignments = @role_assignments.values_at((@page_limit * (@current_page - 1))..(@page_limit * @current_page - 1)).compact
    end

    @role_assignments_count = RoleAssignment.count

    respond_to do |format|
      format.html { render :layout => 'admin' }
      format.json do
        permissions = @role_assignments.map do |ra|
          { :user_login => ra.user.login,
            :node_title => ra.node.path.all(:include => :content).map { |n| n.content.content_title }.join(" > "),
            :name       => RoleAssignment::ROLES[ra.name.intern],
            :id         => ra.id
          }
        end
        render :json => { :permissions => permissions, :total_count => @role_assignments_count }.to_json, :status => :ok
      end
    end
  end

  # * GET /admin/permissions/new
  def new
    @role_assignment = RoleAssignment.new(:name => 'editor')
  end

  # * POST /admin/permissions.json
  # * POST /admin/permissions.xml
  def create
    respond_to do |format|
      @user            = User.find_by_login(params[:role_assignment][:user_login])
      @role_assignment = RoleAssignment.new(:user => @user, :node_id => params[:node_id], :name => params[:role_assignment][:name])

      if @role_assignment.save
        format.html # create.html.erb
        format.xml  { head :ok }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @role_assignment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Destroys a +RoleAssignment+.
  # * DELETE /admin/permissions/:id.json
  def destroy
    @ra = RoleAssignment.find(params[:id])

    respond_to do |format| 
      if @ra.user == current_user
        error = I18n.t('permissions.cant_destroy_from_yourself')
        @ra.errors.add_to_base(error)
        format.json { render :json => { :errors => @ra.errors.full_messages }.to_json, :status => :unprocessable_entity }
      else
        @ra.destroy
        format.json { head :ok }
      end
    end
  end

  protected

    # Finds sorting parameters.
    def set_sorting
      if extjs_sorting?
        @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')

        # We can't sort the polymorphic node relationship in SQL...
        if params[:sort].include?('node')
          @sort_by_node = true
        else
          # ...but we can sort all non-polymorphic relationships
          first, *last = params[:sort].split('_')
          last = last.join('_') if last.is_a?(Array) # join again for columns like email_address
          @sort_field = (last.size > 0 ? "#{first.pluralize}.#{last}" : first)
          # Do not quote_column_name, because PostgreSQL will fail
          # and we already added quotes in the line above.
          #@sort_field = ActiveRecord::Base.connection.quote_column_name(@sort_field)
        end
      else
        @sort_field = 'users.login'
      end
      @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id/
    end
end
