# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Calendar+ objects.
class CalendarsController < ApplicationController

  # The +show+ action needs a +Calendar+ object to work with.  
  before_filter :find_calendar, :only => [ :show , :tomorrow ]

  # * GET /calendars.atom
  def index
    respond_to do |format|
      format.atom {
        combined_calendar = CombinedCalendar.first
        if combined_calendar.blank?
          raise ActiveRecord::RecordNotFound
        else
          redirect_to :controller => :combined_calendars, :action => :show, :id => combined_calendar.id, :format => :atom
        end
      }
    end
  end

  # * GET /calendars/:id/tomorrow.atom
  def tomorrow
    tomorrow        = Date.tomorrow
    conditions      = [ '(start_time BETWEEN :start_time AND :end_time) OR (end_time BETWEEN :start_time AND :end_time)', { :start_time => tomorrow.beginning_of_day, :end_time => tomorrow.end_of_day } ]
    @calendar_items = @calendar.calendar_items.find_accessible(:all, :include => :node, :conditions => conditions, :order => 'start_time', :for => current_user)
    @feed_title     = I18n.t('calendars.tomorrow')

    respond_to do |format|
      format.atom { render :action => 'index', :layout => false }
    end
  end

  # * GET /calendars/:id
  # * GET /calendars/:id.atom
  # * GET /calendars/:id.xml
  def show
    respond_to do |format|
      format.html do
        @date = Date.parse(params[:date]) rescue Date.today
        @date = Date.today if !@date.valid_gregorian_date?

        @calendar_items = @calendar.calendar_items.find_all_for_month_of(@date, current_user).group_by {|ci| ci.start_time.mday }
      end
      format.atom do
        @calendar_items = @calendar.calendar_items.find_accessible(:all, :include => :node, :order => 'start_time', :for => current_user, :conditions => ['nodes.ancestry = ? ', @calendar.node.child_ancestry])
        render :layout => false
      end
      format.xml { render :xml => @calendar }
    end
  end
 
protected

  # Finds the +Calendar+ object corresponding to the passed in +id+ parameter.
  def find_calendar
    @calendar = @node.approved_content
  end
end
