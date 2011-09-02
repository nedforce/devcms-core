# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +CombinedCalendar+ objects.
class Admin::CombinedCalendarsController < Admin::AdminController
  
   # The +create+ action needs the parent +Node+ object to link the new +CombinedCalendar+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]
  
  # The +show+, +edit+ and +update+ actions need a +CombinedCalendar+ object to act upon.
  before_filter :find_combined_calendar,   :only => [ :show, :edit, :update ]

  before_filter :find_calendar_items,      :only => :show

  before_filter :set_commit_type,          :only => [ :create, :update ]
  
  layout false
  
  require_role [ 'admin', 'final_editor' ], :except => [ :index, :show ]

  # * GET /admin/combined_calendars/:id
  # * GET /admin/combined_calendars/:id.xml
  def show
    @calendar = @combined_calendar

    respond_to do |format|
      format.html { render :partial => '/admin/calendars/show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @combined_calendar }
    end
  end  
  
  # * GET /admin/combined_calendars/new
  def new
    @combined_calendar = CombinedCalendar.new(params[:combined_calendar])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @combined_calendar }}
    end
  end
  
  # * GET /admin/combined_calendars/:id/edit
  def edit
    @combined_calendar.attributes = params[:combined_calendar]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @combined_calendar }}
    end
  end
  
  # * POST /admin/combined_calendars
  # * POST /admin/combined_calendars.xml
  def create
    @combined_calendar        = CombinedCalendar.new(params[:combined_calendar])
    @combined_calendar.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @combined_calendar.valid?
        @calendar = @combined_calendar
        format.html { render :action => 'create_preview', :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @combined_calendar, :status => :created, :location => @combined_calendar }
      elsif @commit_type == 'save' && @combined_calendar.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @combined_calendar, :status => :created, :location => @combined_calendar }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @combined_calendar }, :status => :unprocessable_entity }
        format.xml  { render :xml => @combined_calendar.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # * PUT /admin/combined_calendars/:id
  # * PUT /admin/combined_calendars/:id.xml
  def update
    @combined_calendar.attributes = params[:combined_calendar]

    respond_to do |format|
      if @commit_type == 'preview' && @combined_calendar.valid?
        format.html {
          @calendar = @combined_calendar
          find_calendar_items
          render :action => 'update_preview', :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @combined_calendar, :status => :created, :location => @combined_calendar }
      elsif @commit_type == 'save' && @combined_calendar.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @combined_calendar }, :status => :unprocessable_entity }
        format.xml  { render :xml => @combined_calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +CombinedCalendar+ object corresponding to the passed in +id+ parameter.
  def find_combined_calendar
    @combined_calendar = CombinedCalendar.find(params[:id], :include => :node).current_version
  end

  def find_calendar_items
    @date           = Date.today
    @calendar_items = @combined_calendar.calendar_items.find_all_for_month_of(Date.today).group_by { |ci| ci.start_time.mday }
  end  
end
