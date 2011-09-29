# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Calendar+ objects.
class Admin::CalendarsController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +Calendar+ content node to.
  prepend_before_filter :find_parent_node,    :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +Calendar+ object to act upon.
  before_filter         :find_calendar,       :only => [ :show, :edit, :update ]

  before_filter         :find_calendar_items, :only => :show

  before_filter         :set_commit_type,     :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor' ], :except => [ :index, :show ]

  # * GET /admin/calendars/:id
  # * GET /admin/calendars/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @calendar }
    end
  end  

  # * GET /admin/calendars.json?node=1&active_node_id=2
  # 
  # *parameters*
  # 
  # +node+ - Id of the node of which the children are requested.
  # +super_node+ - Id of the node of which the children are requested, when also a year and/or month is specified.
  # +active_node_id+ - (Optional) Id of the active node. If the active node is contained by this calendar, the containing year and month will auto-expand.
  def index
    respond_to do |format|
      node_id        = params[:super_node] || params[:node]
      @calendar_node = Node.find(node_id)

      active_node                  = params[:active_node_id] ? Node.find(params[:active_node_id]) : nil 
      archive_includes_active_node = active_node && @calendar_node.children.include?(active_node)

      parse_date_parameters # See +Admin::AdminController+.

      format.json do
        if @year && @month
          @calendar_item_nodes = @calendar_node.content.find_all_items_for_month(@year, @month).map(&:node)
          render :json => @calendar_item_nodes.map { |node| node.to_tree_node_for(current_user) }.to_json
        else
          role        = current_user.role_on(@calendar_node)
          common_hash = { :treeLoaderName => Node.content_type_configuration('Calendar')[:tree_loader_name], :userRole => role ? role.name : '' }
          now         = Time.now          

          if @year
            @months = @calendar_node.content.find_months_with_items_for_year(@year).map do |m|
              active_node_date           = active_node.content.publication_start_date if archive_includes_active_node
              month_includes_active_node = archive_includes_active_node && (active_node_date.year == @year && active_node_date.month == m)

              { 
                :text        => Date::MONTHNAMES[m].capitalize,
                :expanded    => month_includes_active_node || (!archive_includes_active_node && (@year == now.year && m == now.month)),
                :extraParams => {
                  :super_node => node_id,
                  :year       => @year,
                  :month      => m
                }
              }.reverse_merge(common_hash)
            end

            render :json => @months.to_json
          else
            @years = @calendar_node.content.find_years_with_items.map do |y|
              year_includes_active_node = archive_includes_active_node ? (active_node.content.publication_start_date.year == y) : false
              { 
                :text        => y,
                :expanded    => year_includes_active_node || (!archive_includes_active_node && (y == now.year)),
                :extraParams => {
                  :super_node => node_id,
                  :year       => y
                }
              }.reverse_merge(common_hash)
            end

            render :json => @years.to_json
          end
        end
      end
    end
  end

  # * GET /admin/calendars/new
  def new
    @calendar = Calendar.new(params[:calendar])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @calendar }}
    end
  end

  # * GET /admin/calendars/:id/edit
  def edit
    @calendar.attributes = params[:calendar]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @calendar }}
    end
  end

  # * POST /admin/calendars
  # * POST /admin/calendars.xml
  def create
    @calendar        = Calendar.new(params[:calendar])
    @calendar.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @calendar.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @calendar }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @calendar, :status => :created, :location => @calendar }
      elsif @commit_type == 'save' && @calendar.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @calendar, :status => :created, :location => @calendar }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @calendar }, :status => :unprocessable_entity }
        format.xml  { render :xml => @calendar.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # * PUT /admin/calendars/:id
  # * PUT /admin/calendars/:id.xml
  def update
    @calendar.attributes = params[:calendar]

    respond_to do |format|
      if @commit_type == 'preview' && @calendar.valid?
        format.html {
          find_calendar_items
          render :template => 'admin/shared/update_preview', :locals => { :record => @calendar }, :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @calendar, :status => :created, :location => @calendar }
      elsif @commit_type == 'save' && @calendar.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @calendar }, :status => :unprocessable_entity }
        format.xml  { render :xml => @calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Calendar+ object corresponding to the passed in +id+ parameter.
  def find_calendar
    @calendar = Calendar.find(params[:id], :include => [ :node ]).current_version
  end

  def find_calendar_items
    @calendar_items = @calendar.calendar_items.find_all_for_month_of(Date.today, current_user).group_by {|ci| ci.start_time.mday }
  end
end
