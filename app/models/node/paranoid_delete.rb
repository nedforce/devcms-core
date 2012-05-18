module Node::ParanoidDelete
  
  def self.included(base)
    base.class_eval do
      extend(ClassMethods)
    
      if base.content_columns.any? { |column| column.name == 'deleted_at' }
        default_scope :order => :position, :conditions => "#{base.table_name}.deleted_at IS NULL"
      else
        default_scope :order => :position
      end
    
      define_callbacks  :before_paranoid_delete, :after_paranoid_delete,
                        :before_paranoid_restore, :after_paranoid_restore
    end
  end
  
  # Paranoid deletes a node and all its descendants, and ensures the appropriate callbacks are executed.
  def paranoid_delete!
    time = Time.now
    terminator = Proc.new { |result, object| result == false }
    nodes_to_paranoid_delete_ids = self.descendant_ids
    
    self.class.transaction do
      return false unless self.run_paranoid_callbacks(:before_paranoid_delete, terminator, nodes_to_paranoid_delete_ids)

      self.updated_at = time
      self.deleted_at = time
      self.class.update_all({ :updated_at => time, :deleted_at => time }, [ 'id IN (?)', nodes_to_paranoid_delete_ids + [ self.id ] ])
      
      return false unless self.run_paranoid_callbacks(:after_paranoid_delete, terminator, nodes_to_paranoid_delete_ids)
    end
    
    true
  end
  
  # Restores a paranoid deleted node and all its descendants, and ensures the appropriate callbacks are executed.
  def paranoid_restore!
    self.class.unscoped do
      raise 'Cannot restore paranoid deleted node if parent is also paranoid deleted!' if self.parent && self.parent.deleted_at.present?
    end

    time = Time.now
    terminator = Proc.new { |result, object| result == false }
    nodes_to_paranoid_restore_ids = self.descendant_including_deleted_ids

    self.class.transaction do
     return false unless self.run_paranoid_callbacks(:before_paranoid_restore, terminator, nodes_to_paranoid_restore_ids)

     self.class.unscoped do
       self.updated_at = time
       self.deleted_at = nil
       self.class.update_all({ :updated_at => time, :deleted_at => nil }, [ 'id IN (?)', nodes_to_paranoid_restore_ids + [ self.id ] ])
     end

     return false unless self.run_paranoid_callbacks(:after_paranoid_restore, terminator, nodes_to_paranoid_restore_ids)
    end

    true
  end
  
  # Use this method to retrieve all descendant records, including the ones that have been marked as paranoid deleted
  def descendants_including_deleted
    self.class.unscoped do 
      self.base_class.all(:conditions => descendant_conditions) 
    end
  end
  
  # Use this method to retrieve all ancestor records, including the ones that have been marked as paranoid deleted
  def ancestors_including_deleted
    self.class.unscoped do 
      self.base_class.all(:conditions => ancestor_conditions) 
    end
  end
  
  # Use this method to retrieve all descendant record ids, including the ones that have been marked as paranoid deleted
  def descendant_including_deleted_ids
    self.class.unscoped do 
      self.base_class.all(:conditions => descendant_conditions, :select => self.base_class.primary_key).collect(&self.base_class.primary_key.to_sym)
    end
  end
  
  # Use this method to retrieve all ancestor record ids, including the ones that have been marked as paranoid deleted
  def ancestor_including_deleted_ids
    self.class.unscoped do 
      self.base_class.all(:conditions => ancestor_conditions, :select => self.base_class.primary_key).collect(&self.base_class.primary_key.to_sym)
    end
  end
  
  module ClassMethods
    def unscoped(&block)
      return unless block_given?
      self.with_exclusive_scope do
        self.with_scope(:find => { :order => "(case when #{table_name}.#{ancestry_column} is null then 0 else 1 end), #{table_name}.#{ancestry_column}" }, &block)
      end
    end
    
    # Use this method to retrieve all paranoid deleted node records
    def deleted
      self.unscoped do
        self.all(:conditions => "#{self.table_name}.deleted_at IS NOT NULL")
      end
    end
    
    # Use this method to retrieve all paranoid deleted node records that do not have paranoid deleted parents
    def top_level_deleted(type = :all, *args)
      options = args.extract_options!
      
      conditions = "#{self.table_name}.deleted_at IS NOT NULL AND NOT EXISTS (SELECT * FROM #{self.table_name} AS parents WHERE parents.deleted_at IS NOT NULL AND #{self.table_name}.ancestry = parents.ancestry || '/' || parents.id )"
      
      conditions = merge_conditions(conditions, options.delete(:conditions)) if options.has_key?(:conditions)
      
      self.with_exclusive_scope do
        self.find(type, { :conditions => conditions }.merge(options))
      end
    end
    
    def top_level_deleted_count
      self.with_exclusive_scope do
        self.count(:conditions => "#{self.table_name}.deleted_at IS NOT NULL AND NOT EXISTS (SELECT * FROM #{self.table_name} AS parents WHERE parents.deleted_at IS NOT NULL AND #{self.table_name}.ancestry = parents.ancestry || '/' || parents.id )")
      end
    end

    # Use this method to retrieve all node records, including the ones that have been marked as paranoid deleted
    def all_including_deleted(*args)
      self.unscoped do
        self.all(*args)
      end
    end

    # Use this method to count all node records, including the ones that have been marked as paranoid deleted
    def count_including_deleted(*args)
      self.unscoped do
        self.count(*args)
      end
    end
    
    def find_paranoid_hidden_content(content_type, content_id)
      content_klass = content_type.constantize

      content_klass.send(:with_exclusive_scope) do
        content_klass.find(content_id)
      end
    end
    
    # Deletes ALL paranoid deleted nodes and content, use at own risk ;-)
    def delete_all_paranoid_deleted_content!
      self.transaction do
        self.unscoped do
          self.delete_all 'deleted_at IS NOT NULL'
        end
      
        # This can be optimized to iterate only over the content type tables
        # that actually contain paranoid deleted entries, by first
        # querying the node table for all paranoid deleted nodes.
        # For now, this should suffice.
        DevCMSCore.registered_content_types.each do |content_type|
          content_klass = content_type.constantize
          
          content_klass.send(:with_exclusive_scope) do
            content_klass.delete_all 'deleted_at IS NOT NULL'
          end
        end
      end
    end
  end
  
protected
  
  def run_paranoid_callbacks(callback, terminator, nodes_to_trigger_content_callbacks_ids)    
    Node.unscoped do
      return false unless self.run_callbacks(callback, &terminator) && 
                          self.class.find_paranoid_hidden_content(self.sub_content_type, self.content_id).run_callbacks(callback, &terminator)

      Node.find_each(:conditions => { :id => nodes_to_trigger_content_callbacks_ids }) do |node|
        return false unless self.class.find_paranoid_hidden_content(node.sub_content_type, node.content_id).run_callbacks(callback, &terminator)
      end
    end

    true
  end
end