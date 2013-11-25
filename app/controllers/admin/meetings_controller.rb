# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Meeting+ objects.
class Admin::MeetingsController < Admin::AdminController
  before_filter :default_format_json,  :only => :destroy

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
      format.html { render :partial => '/admin/meetings/show', :locals => { :record => @meeting }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @meeting }
    end
  end

  # * GET /admin/meetings/:id/previous
  # * GET /admin/meetings/:id/previous.xml
  def previous
    @meeting = @meeting.previous_version
    show
  end

  # * GET /admin/meetings/new
  def new
    @meeting = Meeting.new(params[:meeting] || {})

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @meeting }}
    end
  end

  # * GET /admin/meetings/:id/edit
  def edit
    @meeting.attributes = params[:meeting]
    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @meeting }}
    end
  end

  # * POST /admin/meetings
  # * POST /admin/meetings.xml
  def create
    @meeting        = Meeting.new(params[:meeting])
    @meeting.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @meeting.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @meeting }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @meeting, :status => :created, :location => @meeting }
      elsif @commit_type == 'save' && @meeting.save(:user => current_user)
        format.html do
          if params[:continue].present?
            find_meeting_categories

            @meeting = Meeting.new
            render :template => 'admin/shared/new', :locals => { :record => @meeting }, :status => :success
          else
            render :template => 'admin/shared/create'
          end
        end
        format.xml  { render :xml => @meeting, :status => :created, :location => @meeting }
      else
        format.html do
          find_meeting_categories
          render :template => 'admin/shared/new', :locals => { :record => @meeting }, :status => :unprocessable_entity
        end
        format.xml  { render :xml => @meeting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/meetings/:id
  # * PUT /admin/meetings/publication_date1.xml
  def update
    @meeting.attributes = params[:meeting]

    respond_to do |format|
      if @commit_type == 'preview' && @meeting.valid?
        format.html do
          find_children
          render :template => 'admin/shared/update_preview', :locals => { :record => @meeting }, :layout => 'admin/admin_preview'
        end
        format.xml  { render :xml => @meeting, :status => :created, :location => @meeting }
      elsif @commit_type == 'save' && @meeting.save(:user => current_user, :approval_required => @for_approval)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html do
          find_meeting_categories
          render :template => 'admin/shared/edit', :locals => { :record => @meeting }, :status => :unprocessable_entity
        end
        format.xml  { render :xml => @meeting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/meetings/:id
  def destroy
    CalendarItem.destroy_calendar_item(@meeting, true)

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
    @meeting = Meeting.find(params[:id], :include => :node).current_version
  end

  # Finds all MeetingCategory objects.
  def find_meeting_categories
    @categories = MeetingCategory.all(:order => 'name')
  end
end
