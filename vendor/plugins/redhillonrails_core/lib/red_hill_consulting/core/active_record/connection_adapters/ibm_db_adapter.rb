module RedHillConsulting::Core::ActiveRecord::ConnectionAdapters
  module IBM_DBAdapter
    def foreign_keys(table_name, name = nil)
      load_foreign_keys(<<-SQL, name)
        SELECT * FROM SYSCAT.REFERENCES WHERE TABNAME='#{table_name.upcase}' AND TABSCHEMA='#{schema.upcase}'
      SQL
    end
    
    def reverse_foreign_keys(table_name, name = nil)
      load_foreign_keys(<<-SQL, name)
        SELECT * FROM SYSCAT.REFERENCES WHERE REFTABNAME='#{table_name.upcase}' AND REFTABSCHEMA='#{schema.upcase}'
      SQL
    end

    def views(name = nil)
      select_all(<<-SQL, name).map { |row| row['viewname'] }
        SELECT VIEWNAME FROM SYSCAT.VIEWS WHERE VIEWSCHEMA='#{schema.upcase}'
      SQL
    end
    
    def view_definition(view_name, name = nil)
      result = select_all(<<-SQL, name)
        SELECT TEXT
          FROM SYSCAT.VIEWS
         WHERE VIEWNAME='#{view_name.upcase}'
           AND VIEWSCHEMA='#{schema.upcase}'
      SQL
      row = result.first
      unless row.nil?
        row['text'] =~ /^(CREATE VIEW "?[\d\w_]+"? AS )(.*)$/i
        return $2
      end
    end
    
    private

    def load_foreign_keys(sql, name = nil)
      foreign_keys = []

      select_all(sql, name).each do |reference|
        constraint = reference['constname']
        schema = reference['tabschema'].strip.downcase
        table = reference['tabname'].downcase
        cols = reference['fk_colnames'].strip.downcase
        ref_schema = reference['reftabschema'].strip.downcase
        ref_table = reference['reftabname'].downcase
        ref_cols = reference['pk_colnames'].strip.downcase
        if reference['updaterule'] == 'R'
          update_action = :restrict
        else
          update_action = nil # NO ACTION
        end
        
        delete_action = case reference['deleterule']
                              when 'A'
                                nil # NO ACTION
                              when 'R'
                                :restrict
                              when 'C'
                                :cascade
                              when 'N'
                                :set_null
                              end

        # Only qualify schemas when they specifically target an external schema
        if schema == @schema
          from_table = table
        else
          from_table = "#{schema}.#{table}"
        end
        
        if ref_schema == @schema
          ref_table = ref_table
        else
          ref_table = "#{ref_schema}.#{ref_table}"
        end
        
        foreign_keys << ForeignKeyDefinition.new(constraint, from_table, cols, ref_table, ref_cols, update_action, delete_action)
      end

      foreign_keys
    end
  end
end
