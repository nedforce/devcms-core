module DevcmsCore
  module CalendarItemsAssociationExtensions
    def find_all_for_month_of(date)
      start_of_month = date.start_of_month.to_time.utc
      end_of_month   = date.end_of_day.end_of_month.to_time.utc

      # There is a bug in certain Ruby versions where +end_of_month+ does not
      # take Gregorian leap years into account, so it returns 29 February for a
      # year in which there was none.
      #
      # Known good Ruby version: ruby 1.8.6 (2007-09-24 patchlevel 111)
      # Known bad Ruby version: ruby-enterprise-1.8.7-2010.02
      if end_of_month.month == 2 && end_of_month.day == 29 && !Date.gregorian_leap?(end_of_month.year)
        end_of_month = end_of_month - 1.day
      end

      conditions = [
        '((start_time BETWEEN :start_of_month AND :end_of_month) OR (end_time BETWEEN :start_of_month AND :end_of_month) OR (start_time < :start_of_month AND end_time > :end_of_month))',
        { start_of_month: start_of_month, end_of_month: end_of_month }
      ]

      accessible.where(conditions).reorder('start_time')
    end

    def all_for_year(year) #:nodoc:
      year_time     = Date.civil(year).to_time
      start_of_year = year_time.beginning_of_year
      end_of_year   = year_time.end_of_year

      conditions = [
        '((date(start_time) BETWEEN :start_of_year AND :end_of_year) OR (date(end_time) BETWEEN :start_of_year AND :end_of_year) OR (date(start_time) < :start_of_year AND date(end_time) > :end_of_year))',
        { start_of_year: start_of_year, end_of_year: end_of_year }
      ]

      accessible.where(conditions).reorder('start_time')
    end

    def exists_after_date?(date = Date.today) #:nodoc:
      gregorian_date?(date) && accessible.all(conditions: ['? < date(end_time)', date], limit: 1).size > 0
    end

    def exists_before_date?(date = Date.today) #:nodoc:
      gregorian_date?(date) && accessible.all(conditions: ['? > date(start_time)', date], limit: 1).size > 0
    end

    # Checks if the date is between the first and the last known event
    def date_in_range?(date = Date.now)
      min = accessible.minimum(:start_time)
      max = accessible.maximum(:end_time) || accessible.maximum(:start_time)
      min.present? && max.present? && gregorian_date?(date) && (min.to_date..max.to_date).include?(date)
    end

    def current_and_future(time = Time.now, limit = 10) #:nodoc:
      accessible.where(['(? < start_time OR ? < end_time)', time, time]).limit(limit).reorder('start_time ASC')
    end

    def gregorian_date?(date)
      return false if date.nil?
      (date.month == 2 && date.day == 29) ? Date.gregorian_leap?(date.year) : true
    end
  end
end
