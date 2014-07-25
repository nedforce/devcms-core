# Required for ActiveRecord 2.3.9 and above

module AssociationPreloadFix
  private

  def preload_belongs_to_association(records, reflection, preload_options={})
    return if records.first.send("loaded_#{reflection.name}?")
    options = reflection.options
    primary_key_name = reflection.primary_key_name

    if options[:polymorphic]
      polymorph_type = options[:foreign_type]
      klasses_and_ids = {}

      # Construct a mapping from klass to a list of ids to load and a mapping of those ids back to their parent_records
      records.each do |record|
        if klass = record.send(polymorph_type)
          klass_id = record.send(primary_key_name)
          if klass_id
            id_map = klasses_and_ids[klass] ||= {}
            id_list_for_klass_id = (id_map[klass_id.to_s] ||= [])
            id_list_for_klass_id << record
          end
        end
      end
      klasses_and_ids = klasses_and_ids.to_a
    else
      id_map = {}
      records.each do |record|
        key = record.send(primary_key_name)
        if key
          mapped_records = (id_map[key.to_s] ||= [])
          mapped_records << record
        end
      end
      klasses_and_ids = [[reflection.klass.name, id_map]]
    end

    klasses_and_ids.each do |klass_and_id|
      klass_name, id_map = *klass_and_id
      next if id_map.empty?
      klass = klass_name.constantize

      table_name = klass.quoted_table_name
      primary_key = reflection.options[:primary_key] || klass.primary_key
      column_type = klass.columns.detect{ |c| c.name == primary_key }.type
      ids = id_map.keys.map do |id|
        if column_type == :integer
          id.to_i
        elsif column_type == :float
          id.to_f
        else
          id
        end
      end
      conditions = "#{table_name}.#{connection.quote_column_name(primary_key)} #{in_or_equals_for_ids(ids)}"
      conditions << append_conditions(reflection, preload_options)
      find_options = { :conditions => [conditions, ids], :include => options[:include],
                       :select => options[:select], :joins => options[:joins], :order => options[:order] }

      associated_records = klass.send(klass == self ? :with_exclusive_scope : :with_scope, :find => find_options) { klass.all }
      set_association_single_records(id_map, reflection.name, associated_records, primary_key)
    end
  end

  def find_associated_records(ids, reflection, preload_options)
    options = reflection.options
    table_name = reflection.klass.quoted_table_name

    if interface = reflection.options[:as]
      parent_type = if reflection.active_record.abstract_class?
        self.base_class.sti_name
      else
        reflection.active_record.sti_name
      end

      conditions = "#{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_id"} #{in_or_equals_for_ids(ids)} and #{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_type"} = '#{parent_type}'"
    else
      foreign_key = reflection.primary_key_name
      conditions = "#{reflection.klass.quoted_table_name}.#{foreign_key} #{in_or_equals_for_ids(ids)}"
    end

    conditions << append_conditions(reflection, preload_options)

    find_options = { :select => (preload_options[:select] || options[:select] || "#{table_name}.*"),
                     :include => preload_options[:include] || options[:include], :conditions => [conditions, ids],
                     :joins => options[:joins], :group => preload_options[:group] || options[:group],
                     :order => preload_options[:order] || options[:order] }

    reflection.klass.send(reflection.klass == self ? :with_exclusive_scope : :with_scope, :find => find_options) { reflection.klass.all }
  end

  def preload_has_and_belongs_to_many_association(records, reflection, preload_options={})
    table_name = reflection.klass.quoted_table_name
    id_to_record_map, ids = construct_id_map(records)
    records.each { |record| record.send(reflection.name).loaded }
    options = reflection.options

    conditions = "t0.#{reflection.primary_key_name} #{in_or_equals_for_ids(ids)}"
    conditions << append_conditions(reflection, preload_options)

    find_options = { :conditions => [conditions, ids], :include => options[:include], :order => options[:order],
                     :joins => "INNER JOIN #{connection.quote_table_name options[:join_table]} t0 ON #{reflection.klass.quoted_table_name}.#{reflection.klass.primary_key} = t0.#{reflection.association_foreign_key}",
                     :select => "#{options[:select] || table_name+'.*'}, t0.#{reflection.primary_key_name} as the_parent_record_id" }

    associated_records = reflection.klass.send(reflection.klass == self ? :with_exclusive_scope : :with_scope, :find => find_options) { reflection.klass.all }
    set_association_collection_records(id_to_record_map, reflection.name, associated_records, 'the_parent_record_id')
  end

#   def find_associated_records(ids, reflection, preload_options)
#     options = reflection.options
#     table_name = reflection.klass.quoted_table_name
# 
#     if interface = reflection.options[:as]
#       parent_type = if reflection.active_record.abstract_class?
#         self.base_class.sti_name
#       else
#         # Instead of reflection.active_record.base_class.sti_name, otherwise fails for Site, CalendarItem, etc.
#         reflection.active_record.base_class.sti_name
#       end
# 
#       conditions = "#{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_id"} #{in_or_equals_for_ids(ids)} and #{reflection.klass.quoted_table_name}.#{connection.quote_column_name "#{interface}_type"} = '#{parent_type}'"
#     else
#       foreign_key = reflection.primary_key_name
#       conditions = "#{reflection.klass.quoted_table_name}.#{foreign_key} #{in_or_equals_for_ids(ids)}"
#     end
# 
#     conditions << append_conditions(reflection, preload_options)
# 
#     reflection.klass.with_exclusive_scope do
#       reflection.klass.find(:all,
#                           :select => (preload_options[:select] || options[:select] || "#{table_name}.*"),
#                           :include => preload_options[:include] || options[:include],
#                           :conditions => [conditions, ids],
#                           :joins => options[:joins],
#                           :group => preload_options[:group] || options[:group],
#                           :order => preload_options[:order] || options[:order])
#     end
#   end
end
