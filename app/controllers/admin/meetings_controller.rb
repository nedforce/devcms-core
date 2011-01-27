# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Meeting+ objects.
class Admin::MeetingsController < Admin::AdminController

  # The +new+ and +create+ actions needs a parent +Node+ object.
  prepend_before_filter :find_parent_node,  :only => [ :new, :create ]

  # The +new+, +create+ and +delete+ actions need a +Calendar+ object to act upon.
  before_filter :find_calendar,             :only => [ :new, :create ]

  # The +show+, +edit+, +update+ and +delete+ actions need a +Meeting+ object to act upon.
  before_filter :find_meeting,              :only => [ :show, :edit, :update, :previous, :destroy ]

  before_filter :find_meeting_categories,   :only => [ :new, :edit ]

  # Parse the start and end times for the +create+ and +update+ actions.
  before_filter :parse_start_and_end_times, :only => [ :create, :update ]

  before_filter :find_children,             :only => [ :show, :previous ]

  before_filter :set_commit_type,           :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /admin/meetings/:id
  # * GET /admin/meetings/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => '/admin/calendar_items/show', :locals => { :record => @calendar_item }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @calendar_item }
    end
  end 

  # * GET /admin/meetings/:id/previous
  # * GET /admin/meetings/:id/previous.xml
  def previous
    @calendar_item = @calendar_item.previous_version
    show
  end

  # * GET /admin/meetings/new
  def new
    @repeat_interval_multipliers   = CalendarItem.repeat_interval_multipliers
    @repeat_interval_granularities = CalendarItem.repeat_interval_granularities
    @calendar_item                 = Meeting.new(params[:calendar_item] || {})

    render :template => '/admin/calendar_items/new'
  end
  
  # * GET /admin/meetings/:id/edit
  def edit
    @calendar_item.attributes = params[:calendar_item]
    render :template => '/admin/calendar_items/edit'
  end

  # * POST /admin/meetings
  # * POST /admin/meetings.xml
  def create
    @calendar_item        = Meeting.new(params[:calendar_item])
    @calendar_item.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @calendar_item.valid?
        format.html { render :template => '/admin/calendar_items/create_preview', :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @calendar_item, :status => :created, :location => @calendar_item }
      elsif @commit_type == 'save' && @calendar_item.save_for_user(current_user)
        format.html do
          if params[:continue].present?
            @repeat_interval_multipliers   = CalendarItem.repeat_interval_multipliers
            @repeat_interval_granularities = CalendarItem.repeat_interval_granularities
            find_meeting_categories

            @calendar_item = Meeting.new
            render :template => '/admin/calendar_items/new'
          else
            render :template => 'admin/shared/create'
          end
        end
        format.xml  { render :xml => @calendar_item, :status => :created, :location => @calendar_item }
      else
        format.html do 
          find_meeting_categories
          @repeat_interval_multipliers   = CalendarItem.repeat_interval_multipliers
          @repeat_interval_granularities = CalendarItem.repeat_interval_granularities
          render :template => '/admin/calendar_items/new'
        end
        format.xml  { render :xml => @calendar_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/meetings/:id
  # * PUT /admin/meetings/publication_date1.xml
  def update
    @calendar_item.attributes = params[:calendar_item]

    respond_to do |format|
      if @commit_type == 'preview' && @calendar_item.valid?
        format.html do
          find_children
          render :template => '/admin/calendar_items/update_preview', :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @calendar_item, :status => :created, :location => @calendar_item }
      elsif @commit_type == 'save' && @calendar_item.save_for_user(current_user, @for_approval)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html do 
          find_meeting_categories
          render :template => '/admin/calendar_items/edit'
        end
        format.xml  { render :xml => @calendar_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/meetings/:id
  def destroy
    CalendarItem.destroy_calendar_item(@calendar_item)

    respond_to do |format|
      format.xml  { head :ok }
      format.json { render :json => { :notice => I18n.t('calendars.succesfully_destroyed') }.to_json, :status => :ok }
    end  
  end

protected

  # Finds the +Calendar+ object corresponding to the parent node's content.
  def find_calendar
    @calendar = @parent_node.content
  end

  # Finds the +Meeting+ object corresponding to the passed in +id+ parameter.
  def find_meeting
    @calendar_item = Meeting.find(params[:id], :include => :node)
  end

  # Finds all MeetingCategory objects.
  def find_meeting_categories
    @categories = MeetingCategory.all(:order => 'name')
  end
end
