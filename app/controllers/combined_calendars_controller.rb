# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +CombinedCalendar+ objects.
class CombinedCalendarsController < ApplicationController
  
  # The +show+ action needs a +CombinedCalendar+ object to work with.  
  before_filter :find_combined_calendar, :only => [:show, :tomorrow]
   
  # * GET /combined_calendars/1
  # * GET /combined_calendars/1.atom
  # * GET /combined_calendars/1.xml
  def show
    respond_to do |format|
      format.html do
        @date = Date.parse(params[:date]) rescue Date.today
        @calendar_items = @calendar.calendar_items.find_all_for_month_of(@date, current_user).group_by {|ci| ci.start_time.mday }
        render :template => 'calendars/show'
      end
      format.atom do
        @calendar_items = @calendar.calendar_items.find_accessible(:all, :include => :node, :for => current_user, :order => 'events.start_time DESC', :limit => 25)
        render :layout => false, :template => 'calendars/show'
      end
      format.xml { render :xml => @calendar }
    end
  end
  
  
  # * GET /combined_calendars/1/tomorrow.atom
  def tomorrow
    tomorrow = Date.tomorrow
    conditions = [ '(start_time BETWEEN :start_time AND :end_time) OR (end_time BETWEEN :start_time AND :end_time)', { :start_time => tomorrow.beginning_of_day, :end_time => tomorrow.end_of_day } ]
    @calendar_items = @calendar.calendar_items.find_accessible(:all, :include => :node, :conditions => conditions, :order => 'events.start_time DESC', :for => current_user)
    @feed_title = I18n.t('calendars.tomorrow')
    respond_to do |format|
      format.atom do
        render :template => 'calendars/index', :layout => false
      end
    end
  end
  
 
protected

  # Finds the +CombinedCalendar+ object corresponding to the passed in +id+ parameter.
  def find_combined_calendar
    @calendar = @node.content
  end

end
