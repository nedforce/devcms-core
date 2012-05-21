module CalendarItemsAssociationExtensions #:nodoc:
  def find_all_for_month_of(date) #:nodoc:
    start_of_month = date.start_of_month
    end_of_month   = date.end_of_month

    # There is a bug in certain Ruby versions where +end_of_month+ does not take
    # Gregorian leap years into account, so it returns 29 February for a year in which
    # there was none.
    #
    # Known good Ruby version: ruby 1.8.6 (2007-09-24 patchlevel 111)
    # Known bad Ruby version: ruby-enterprise-1.8.7-2010.02
    if end_of_month.month == 2 && end_of_month.day == 29 && !Date.gregorian_leap?(end_of_month.year)
      end_of_month = end_of_month - 1.day
    end

    conditions = [
                   '((date(start_time) BETWEEN ? AND ? ) OR (date(end_time) BETWEEN ? AND ?) OR (date(start_time) < ? AND date(end_time) > ?))', 
                   start_of_month, end_of_month, start_of_month, end_of_month, start_of_month, end_of_month 
                 ]

    self.accessible.all(:conditions => conditions, :order => 'start_time')
  end

  def all_for_year(year) #:nodoc:
    start_of_year = DateTime.civil(year)
    end_of_year   = DateTime.civil(year, 12, 31)

    conditions = [
                   '((date(start_time) BETWEEN :start_of_year AND :end_of_year ) OR (date(end_time) BETWEEN :start_of_year AND :end_of_year) OR (date(start_time) < :start_of_year AND date(end_time) > :end_of_year))', 
                   { :start_of_year => start_of_year, :end_of_year => end_of_year }
                 ]

    self.accessible.all(:conditions => conditions, :order => 'start_time')
  end

  def exists_after_date?(date = Date.today) #:nodoc:
    gregorian_date?(date) ? self.accessible.exists?(['? < date(end_time) ', date]) : false
  end

  def exists_before_date?(date = Date.today) #:nodoc:
    gregorian_date?(date) ? self.accessible.exists?(['? > date(start_time)', date]) : false
  end

  # Checks if the date is between the first and the last known event
  def date_in_range?(date = Date.now)
    min = self.accessible.minimum(:start_time)
    max = self.accessible.maximum(:end_time) || self.accessible.maximum(:start_time)
    min.present? && max.present? && gregorian_date?(date) ? (min.to_date..max.to_date).include?(date) : false
  end

  def current_and_future(time = Time.now, limit = 10) #:nodoc:
    self.accessible.all(:conditions => ['( ? < start_time OR ? < end_time )', time, time], :limit => limit, :order => 'start_time')
  end

  def gregorian_date?(date)
    return false if date.nil?
    (date.month == 2 and date.day == 29) ? Date.gregorian_leap?(date.year) : true
  end
end
