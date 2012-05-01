module NodeExtensions::ParanoidDelete
  extend ActiveSupport::Concern    
  
  included do
    if content_columns.any? { |column| column.name == 'deleted_at' }
      default_scope order('nodes.position').where('nodes.deleted_at IS NULL')
    else
      default_scope order('nodes.position')
    end

    define_callbacks :before_paranoid_delete, :after_paranoid_delete, :before_paranoid_restore, :after_paranoid_restore
  end

  module ClassMethods
    def before_paranoid_delete(*args, &block);  set_callback(:before_paranoid_delete, :before, *args, &block)   end  
    def after_paranoid_delete(*args, &block);   set_callback(:after_paranoid_delete, :after, *args, &block)     end     
    def before_paranoid_restore(*args, &block); set_callback(:before_paranoid_restore, :before, *args, &block)  end
    def after_paranoid_restore(*args, &block);  set_callback(:after_paranoid_restore, :after, *args, &block)    end          

    # Use this method to retrieve all paranoid deleted node records
    def deleted
      unscoped{ where("#{self.table_name}.deleted_at IS NOT NULL") }
    end
    
    # Use this method to retrieve all paranoid deleted node records that do not have paranoid deleted parents
    def top_level_deleted(type = :all, *args)
      options = args.extract_options!
      
      conditions = "#{self.table_name}.deleted_at IS NOT NULL AND NOT EXISTS (SELECT * FROM #{self.table_name} AS parents WHERE parents.deleted_at IS NOT NULL AND #{self.table_name}.ancestry = parents.ancestry || '/' || parents.id )"      

      unscoped do
        scope = self.where(conditions).scoped(options)
        scope = scope.where(options.delete(:conditions)) if options.has_key?(:conditions)
        type == :all ? scope : scope.first
      end
    end
    
    def top_level_deleted_count
      unscoped do
        count(:conditions => "#{self.table_name}.deleted_at IS NOT NULL AND NOT EXISTS (SELECT * FROM #{self.table_name} AS parents WHERE parents.deleted_at IS NOT NULL AND #{self.table_name}.ancestry = parents.ancestry || '/' || parents.id )")
      end
    end

    # Use this method to retrieve all node records, including the ones that have been marked as paranoid deleted
    def all_including_deleted(*args)
      unscoped{ all(*args) }
    end

    # Use this method to count all node records, including the ones that have been marked as paranoid deleted
    def count_including_deleted(*args)
      unscoped{ count(*args) }
    end
    
    def find_paranoid_hidden_content(content_type, content_id)
      content_class = content_type.constantize
      content_class.unscoped { content_class.find(content_id) }
    end
    
    # Deletes ALL paranoid deleted nodes and content, use at own risk ;-)
    def delete_all_paranoid_deleted_content!
      self.transaction do
        unscoped{ delete_all 'deleted_at IS NOT NULL' }
      
        # This can be optimized to iterate only over the content type tables
        # that actually contain paranoid deleted entries, by first
        # querying the node table for all paranoid deleted nodes.
        # For now, this should suffice.
        DevcmsCore::Engine.registered_content_types.each do |content_type|   
          content_class = content_type.constantize              
          content_class.unscoped { content_class.delete_all 'deleted_at IS NOT NULL' }
        end
      end
    end
  end
    
  def paranoid_delete!
    return true if deleted_at.present?
    
    time = Time.now
    nodes_to_paranoid_delete_ids = self.descendant_ids
    
    self.class.transaction do
      return false unless run_paranoid_callbacks(:before_paranoid_delete, nodes_to_paranoid_delete_ids)

      # Set updated_at, deleted_at of the in-memory node for the paranoid destroy callbacks
      self.updated_at = time      
      self.deleted_at = time 
      
      # Update with an SQL query
      self.class.update_all({ :updated_at => updated_at, :deleted_at => deleted_at }, [ 'id IN (?)', nodes_to_paranoid_delete_ids + [ self.id ] ])  
      
      return false unless run_paranoid_callbacks(:after_paranoid_delete, nodes_to_paranoid_delete_ids)
    end
    
    true
  end
  
  # Restores a paranoid deleted node and all its descendants, and ensures the appropriate callbacks are executed.
  def paranoid_restore!
    self.class.unscoped do
      raise 'Cannot restore paranoid deleted node if parent is also paranoid deleted!' if parent && parent.deleted_at.present?
    end

    time = Time.now
    nodes_to_paranoid_restore_ids = self.descendant_including_deleted_ids

    self.class.transaction do
      return false unless run_paranoid_callbacks(:before_paranoid_restore, nodes_to_paranoid_restore_ids)

      self.class.unscoped do
       self.updated_at = time
       self.deleted_at = nil
       
       self.class.update_all({ :updated_at => time, :deleted_at => nil }, [ 'id IN (?)', nodes_to_paranoid_restore_ids + [ self.id ] ])
      end

      return false unless run_paranoid_callbacks(:after_paranoid_restore, nodes_to_paranoid_restore_ids)
    end

    true
  end  
  
  # Use this method to retrieve all descendant records, including the ones that have been marked as paranoid deleted
  def descendants_including_deleted
    self.class.unscoped { self.base_class.all(:conditions => descendant_conditions) }
  end
  
  # Use this method to retrieve all ancestor records, including the ones that have been marked as paranoid deleted
  def ancestors_including_deleted
    self.class.unscoped { self.base_class.all(:conditions => ancestor_conditions) }
  end
  
  # Use this method to retrieve all descendant record ids, including the ones that have been marked as paranoid deleted
  def descendant_including_deleted_ids
    self.class.unscoped { self.base_class.all(:conditions => descendant_conditions, :select => self.base_class.primary_key).collect(&self.base_class.primary_key.to_sym) }
  end
  
  # Use this method to retrieve all ancestor record ids, including the ones that have been marked as paranoid deleted
  def ancestor_including_deleted_ids
    self.class.unscoped { self.base_class.all(:conditions => ancestor_conditions, :select => self.base_class.primary_key).collect(&self.base_class.primary_key.to_sym) }
  end  
 
  private

  def run_paranoid_callbacks(callback, nodes_to_trigger_content_callbacks_ids)    
    self.class.unscoped do
      return false unless self.run_callbacks(callback) && self.class.find_paranoid_hidden_content(self.sub_content_type, self.content_id).run_callbacks(callback)

      self.class.where(:id => nodes_to_trigger_content_callbacks_ids).each do |node|
        return false unless self.class.find_paranoid_hidden_content(node.sub_content_type, node.content_id).run_callbacks(callback)
      end
    end

    true    
  end
  
end