module DevcmsCore
  
  module ActsAsArchive
    extend ActiveSupport::Concern

    # Returns the items in this archive.
    def acts_as_archive_items
      self.send(self.acts_as_archive_configuration[:items_name])
    end

    # Finds all items for the month determined by the given +year+, +month+ combination.
    # Extra parameters can be specified with +args+, these will be passed along to the internal +find+ call.
    def find_all_items_for_month(year, month, args = {})
      start_of_month = DateTime.civil(year, month, 1)
      start_of_next_month = start_of_month + 1.month
      date_field_database_name = self.acts_as_archive_configuration[:date_field_database_name]
      options = { :conditions => [ date_field_database_name + ' >= ? AND ' + date_field_database_name + ' < ?', start_of_month, start_of_next_month ], :order => "#{date_field_database_name} DESC" }
      options.update(self.acts_as_archive_configuration[:sql_options]) if self.acts_as_archive_configuration[:sql_options]
      options.update(args)
      self.acts_as_archive_items.all(options)
    end
  
    # Finds all items for the week determined by the given +year+, +week+ combination.
    # Extra parameters can be specified with +args+, these will be passed along to the internal +find+ call.
    def find_all_items_for_week(year, week, args = {})
      start_of_week = Date.commercial(year, week).beginning_of_week
      start_of_next_week = start_of_week.end_of_week + 1.day
      date_field_database_name = self.acts_as_archive_configuration[:date_field_database_name]
      options = { :conditions => [ date_field_database_name + ' >= ? AND ' + date_field_database_name + ' < ?', start_of_week, start_of_next_week ], :order => "#{date_field_database_name} DESC" }
      options.update(self.acts_as_archive_configuration[:sql_options]) if self.acts_as_archive_configuration[:sql_options]
      options.update(args)
      self.acts_as_archive_items.all(options)
    end      

    # Returns an array with all years for which this archive has items.
    def find_years_with_items
      @years = []

      date_field_model_name = self.acts_as_archive_configuration[:date_field_model_name]
    
      self.acts_as_archive_items.all.each do |item|
        year = item.send(date_field_model_name).year
        @years << year unless @years.include?(year)
      end

      @years.sort { |a,b| b <=> a }
    end

    # Returns an array with all years for which this archive has items. This method will be used if weeks
    # are rendered instead of months, as the commercial year can be different for the first week
    # of a new year.     
    def find_commercial_years_with_items
      @years = []

      date_field_model_name = self.acts_as_archive_configuration[:date_field_model_name]
    
      self.acts_as_archive_items.all.each do |item|
        year = item.send(date_field_model_name).to_date.cwyear
        @years << year unless @years.include?(year)
      end

      @years.sort { |a,b| b <=> a }
    end      

    # Returns an array with all months of the given +year+ for which this archive has items.
    def find_months_with_items_for_year(year)
      @months = []
      start_of_year = DateTime.civil(year, 1, 1)
      start_of_next_year = start_of_year + 1.year

      date_field_model_name = self.acts_as_archive_configuration[:date_field_model_name]
      date_field_database_name = self.acts_as_archive_configuration[:date_field_database_name]

      options = { :conditions => [ date_field_database_name + ' >= ? AND ' + date_field_database_name + ' < ?', start_of_year, start_of_next_year ] }
      options.update(self.acts_as_archive_configuration[:sql_options]) if self.acts_as_archive_configuration[:sql_options]

      # TODO: optimize this query
      self.acts_as_archive_items.all(options).each do |item|
        month = item.send(date_field_model_name).month
        @months << month unless @months.include?(month)
      end

      @months.sort { |a,b| b <=> a }
    end
  
    # Returns an array with all weeks of the given +year+ for which this archive has items. Note that
    # this takes into account that a given day in a commercial week can be in a new year, while the commercial
    # week itself can still belong to the previous year.
    def find_weeks_with_items_for_year(year)
      @weeks = []

      start_of_cwyear = Date.commercial(year, 1, 7).beginning_of_week
      star_of_next_cwyear = (Date.valid_commercial?(year, 53, 7) ? Date.commercial(year, 53, 7) : Date.commercial(year, 52, 7)).end_of_week + 1.day

      date_field_model_name = self.acts_as_archive_configuration[:date_field_model_name]
      date_field_database_name = self.acts_as_archive_configuration[:date_field_database_name]

      options = { :conditions => [ date_field_database_name + ' >= ? AND ' + date_field_database_name + ' < ?', start_of_cwyear, star_of_next_cwyear ] }
      options.update(self.acts_as_archive_configuration[:sql_options]) if self.acts_as_archive_configuration[:sql_options]

      # TODO: optimize this query
      self.acts_as_archive_items.all(options).each do |item|
        week = item.send(date_field_model_name).to_date.cweek
        @weeks << week unless @weeks.include?(week)
      end

      @weeks.sort { |a,b| b <=> a }
    end      
  
    # Destroys all items for the given year or month in a year
    def destroy_items_for_year_or_month(year, month = nil, paranoid_delete = false)
      if month.nil?
        destroy_items_for_year(year.to_i, paranoid_delete)
      else
        destroy_items_for_month(year.to_i, month.to_i, paranoid_delete)
      end
    end

    # Destroys all items for the given year
    def destroy_items_for_year(year, paranoid_delete = false)
      (1..12).each do |month|
        destroy_items_for_month(year, month, paranoid_delete)
      end
    end
  
    # Destroys all items for the given month in the given year
    def destroy_items_for_month(year, month, paranoid_delete = false)
      find_all_items_for_month(year, month).each do |item|
        if paranoid_delete
          item.node.paranoid_delete!
        else
          item.destroy
        end
      end
    end
  end
end