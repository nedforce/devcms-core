module Node::ParanoidDelete
  
  def self.included(base)
    base.class_eval do
      extend(ClassMethods)
    
      if base.content_columns.map(&:name).include?('deleted_at')
        default_scope :conditions => base.default_scope_conditions
      end
    
      define_callbacks :before_paranoid_delete, :after_paranoid_delete
    end
  end
  
  def paranoid_delete!
    time = Time.now
    terminator = Proc.new { |result, object| result == false }
    
    self.class.transaction do
      return false unless run_paranoid_delete_callbacks(:before_paranoid_delete, terminator)
      
      self.class.update_all({ :updated_at => time, :deleted_at => time }, [ 'id IN (?)', self.subtree_ids ])
      
      return false unless run_paranoid_delete_callbacks(:after_paranoid_delete, terminator)
    end
    
    true
  end
  
  module ClassMethods
    def default_scope_conditions
      "#{self.table_name}.deleted_at IS NULL"
    end
    
    def unscoped(&block)
      return unless block_given?
      self.with_exclusive_scope &block
    end

    # Use this method to retrieve all node records, including the ones that have been marked as deleted
    def all_including_deleted(*args)
      self.unscoped do
        self.all(*args)
      end
    end

    # Use this method to count all node records, including the ones that have been marked as deleted
    def count_including_deleted(*args)
      self.unscoped do
        self.count(*args)
      end
    end
  end
  
private

  def run_paranoid_delete_callbacks(callback, terminator)
    return false unless self.run_callbacks(callback, &terminator) && self.content.run_callbacks(callback, &terminator)

    self.descendants.each do |descendant|
      # No need to run the callback on descendant itself, as the callback of self takes care of the whole subtree.
      return false unless descendant.content.run_callbacks(callback, &terminator)
    end

    true
  end
  
end