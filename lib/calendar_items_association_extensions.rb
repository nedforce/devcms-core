module CalendarItemsAssociationExtensions #:nodoc:
  def find_all_for_month_of(date, user) #:nodoc:
    start_of_month = date.start_of_month
    end_of_month   = date.end_of_month

    conditions = [
                   '((date(start_time) BETWEEN ? AND ? ) OR (date(end_time) BETWEEN ? AND ?) OR (date(start_time) < ? AND date(end_time) > ?))', 
                   start_of_month, end_of_month, start_of_month, end_of_month, start_of_month, end_of_month 
                 ]

    self.find_accessible(:all, :include => :node, :conditions => conditions, :order => 'start_time', :for => user)
  end
  
  def all_for_year(year, user) #:nodoc:
    start_of_year = DateTime.civil(year)
    end_of_year   = DateTime.civil(year, 12, 31)

    conditions = [
                   '((date(start_time) BETWEEN :start_of_year AND :end_of_year ) OR (date(end_time) BETWEEN :start_of_year AND :end_of_year) OR (date(start_time) < :start_of_year AND date(end_time) > :end_of_year))', 
                   {:start_of_year => start_of_year, :end_of_year => end_of_year}
                 ]

    self.find_accessible(:all, :include => :node, :conditions => conditions, :order => 'start_time', :for => user)
  end
  
  def exists_after_date?(date = Date.today, user = nil) #:nodoc:
    gregorian_date?(date) ? self.find_accessible(:all, :conditions => ['? < date(end_time) ', date], :for => user, :limit => 1).size > 0 : false
  end
  
  def exists_before_date?(date = Date.today, user = nil) #:nodoc:
    gregorian_date?(date) ? self.find_accessible(:all, :conditions => ['? > date(start_time)', date], :for => user, :limit => 1).size > 0 : false
  end
  
  
  def current_and_future_for(user, time = Time.now, limit = 10) #:nodoc:
    self.find_accessible(:all, :conditions => ['( ? < start_time OR ? < end_time )', time, time], :for => user, :limit => limit, :order => 'start_time')
  end
  
  def gregorian_date?(date)
    return false if date.nil?  
    (date.month == 2 and date.day == 29) ? Date.gregorian_leap?(date.year) : true
  end  
    
end
