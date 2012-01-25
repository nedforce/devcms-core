# Required for ActiveRecord 2.3.14
# Allows join clauses for update_all and delete_all calls
# Only works on PostgreSQL 8+
# Currently only works for inner joins

class ActiveRecord::Base
  
  def self.update_all(updates, conditions = nil, options = {})
    sql = "UPDATE #{quoted_table_name} SET #{sanitize_sql_for_assignment(updates)} "

    scope = scope(:find)

    if (scope && scope[:joins]) || options[:joins]
      conditions = add_join_statements_and_determine_conditions!(sql, "FROM", conditions, scope, options)
    end
    
    select_sql = ""
    
    add_conditions!(select_sql, conditions, scope)

    if options.has_key?(:limit) || (scope && scope[:limit])
      # Only take order from scope if limit is also provided by scope, this
      # is useful for updating a has_many association with a limit.
      add_order!(select_sql, options[:order], scope)

      add_limit!(select_sql, options, scope)
      sql.concat(connection.limited_update_conditions(select_sql, quoted_table_name, connection.quote_column_name(primary_key)))
    else
      add_order!(select_sql, options[:order], nil)
      sql.concat(select_sql)
    end

    connection.update(sql, "#{name} Update")
  end
  
  def self.delete_all(conditions = nil, options = {})
    sql = "DELETE FROM #{quoted_table_name} "
    
    scope = scope(:find)
    
    if (scope && scope[:joins]) || options[:joins]
      conditions = add_join_statements_and_determine_conditions!(sql, "USING", conditions, scope, options)
    end

    add_conditions!(sql, conditions, scope)
    connection.delete(sql, "#{name} Delete all")
  end
  
  def self.update_counters(id, counters)
    updates = counters.map do |counter_name, value|
      operator = value < 0 ? '-' : '+'
      quoted_column = connection.quote_column_name(counter_name)
      "#{quoted_column} = COALESCE(#{self.quoted_table_name}.#{quoted_column}, 0) #{operator} #{value.abs}"
    end

    update_all(updates.join(', '), primary_key => id )
  end
  
private

  def self.add_join_statements_and_determine_conditions!(sql, keyword, conditions, scope, options)
    target_tables = []
    target_conditions = []
    
    join_associations = determine_join_associations(options[:joins], scope)
  
    join_associations.each do |assoc|
      join_statement = assoc.association_join
      
      regexp = /\A INNER JOIN (.*) ON (.*)\Z/i
      match = regexp.match(join_statement)
      
      if match
        target_tables += match[1].split(',')
        target_conditions << match[2]
      else
        raise "Unsupported join type for update_all and delete_all statements, aborting!"
      end
    end
  
    unless target_tables.empty?
      sql.concat("#{keyword} #{target_tables.map(&:strip).uniq.join(", ")} ")
      conditions = self.merge_conditions(conditions, *target_conditions)
    end
    
    conditions
  end
  
  def self.determine_join_associations(joins, scope = :auto)
    scope = scope(:find) if :auto == scope
    merged_joins = scope && scope[:joins] && joins ? merge_joins(scope[:joins], joins) : (joins || scope && scope[:joins])
    ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self, merged_joins, nil).join_associations
  end
end
