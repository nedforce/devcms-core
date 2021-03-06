# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +CombinedCalendar+ objects.

class CombinedCalendarsController < ApplicationController
  # The +show+ action needs a +CombinedCalendar+ object to work with.
  before_filter :find_combined_calendar, :only => [ :show, :tomorrow ]

  # * GET /combined_calendars/:id
  # * GET /combined_calendars/:id.atom
  # * GET /combined_calendars/:id.xml
  def show
    respond_to do |format|
      format.html do
        @date = Date.parse(params[:date]) rescue Date.today
        @date = Date.today if !@date.valid_gregorian_date?

        raise ActiveRecord::RecordNotFound if params[:date].present? && !@calendar.calendar_items.date_in_range?(@date)

        @calendar_items = @calendar.calendar_items.find_all_for_month_of(@date).group_by { |ci| ci.start_time.mday }
        render 'calendars/show'
      end
      format.any(:atom, :rss) do
        @calendar_items = @calendar.calendar_items.accessible.all(:include => :node, :order => 'events.start_time DESC', :limit => 25)
        render :layout => false, :template => 'calendars/show'
      end
      format.xml { render :xml => @calendar }
    end
  end

  # * GET /combined_calendars/:id/tomorrow.atom
  def tomorrow
    tomorrow = Date.tomorrow
    conditions = [ '(start_time BETWEEN :start_time AND :end_time) OR (end_time BETWEEN :start_time AND :end_time)', { :start_time => tomorrow.beginning_of_day, :end_time => tomorrow.end_of_day } ]
    @calendar_items = @calendar.calendar_items.accessible.all(:include => :node, :conditions => conditions, :order => 'events.start_time DESC')
    @feed_title = I18n.t('calendars.tomorrow')

    respond_to do |format|
      format.any(:rss, :atom) do
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
