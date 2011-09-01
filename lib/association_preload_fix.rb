# Required for ActiveRecord 2.3.9 and above

module AssociationPreloadFix
  private

  def find_associated_records(ids, reflection, preload_options)
    options = reflection.options
    table_name = reflection.klass.quoted_table_name

    if interface = reflection.options[:as]
      parent_type = if reflection.active_record.abstract_class?
        self.base_class.sti_name
      else
        # Instead of reflection.active_record.base_class.sti_name, otherwise fails for Site, CalendarItem, etc.
        reflection.active_record.base_class.sti_name
      end

      conditions = "#{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_id"} #{in_or_equals_for_ids(ids)} and #{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_type"} = '#{parent_type}'"
    else
      foreign_key = reflection.primary_key_name
      conditions = "#{reflection.klass.quoted_table_name}.#{foreign_key} #{in_or_equals_for_ids(ids)}"
    end

    conditions << append_conditions(reflection, preload_options)

    reflection.klass.with_exclusive_scope do
      reflection.klass.find(:all,
                          :select => (preload_options[:select] || options[:select] || "#{table_name}.*"),
                          :include => preload_options[:include] || options[:include],
                          :conditions => [conditions, ids],
                          :joins => options[:joins],
                          :group => preload_options[:group] || options[:group],
                          :order => preload_options[:order] || options[:order])
    end
  end
end
