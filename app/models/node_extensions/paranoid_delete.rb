module NodeExtensions::ParanoidDelete
  extend ActiveSupport::Concern

  included do
    default_scope ->{ ordered_by_ancestry.order('nodes.position').where(deleted_at: nil) }

    define_callbacks :before_paranoid_delete, :after_paranoid_delete, :before_paranoid_restore, :after_paranoid_restore
  end

  module ClassMethods
    def before_paranoid_delete(*args,  &block); set_callback(:before_paranoid_delete,  :before, *args, &block) end
    def after_paranoid_delete(*args,   &block); set_callback(:after_paranoid_delete,   :after,  *args, &block) end
    def before_paranoid_restore(*args, &block); set_callback(:before_paranoid_restore, :before, *args, &block) end
    def after_paranoid_restore(*args,  &block); set_callback(:after_paranoid_restore,  :after,  *args, &block) end

    # Use this method to retrieve all paranoid deleted node records.
    def deleted
      unscope(where: :deleted_at).where.not(deleted_at: nil)
    end

    def top_level_deleted
      deleted.joins("INNER JOIN nodes AS parents ON (nodes.ancestry = parents.ancestry || '/' || parents.id OR nodes.ancestry = parents.id::varchar) AND parents.deleted_at IS NULL")
    end

    def find_paranoid_hidden_content(content_type, content_id)
      content_class = content_type.constantize
      content_class.unscoped { content_class.find(content_id) }
    end

    # Deletes ALL paranoid deleted nodes and content, use at own risk ;-)
    def delete_all_paranoid_deleted_content!
      transaction do
        unscoped { where('deleted_at IS NOT NULL').delete_all }

        # This can be optimized to iterate only over the content type tables
        # that actually contain paranoid deleted entries, by first
        # querying the node table for all paranoid deleted nodes.
        # For now, this should suffice.
        DevcmsCore::Engine.registered_content_types.each do |content_type|
          content_class = content_type.constantize
          content_class.unscoped { content_class.where('deleted_at IS NOT NULL').delete_all }
        end
      end
    end
  end

  def paranoid_delete!
    if deleted_at.blank?

      time = Time.now
      nodes_to_paranoid_delete_ids = descendant_ids

      self.class.transaction do
        return false unless run_paranoid_callbacks(:before_paranoid_delete, nodes_to_paranoid_delete_ids)

        # Set updated_at, deleted_at of the in-memory node for the paranoid destroy callbacks
        self.updated_at = time
        self.deleted_at = time

        # Update with an SQL query
        self.class.where(id: nodes_to_paranoid_delete_ids + [id]).update_all(updated_at: updated_at, deleted_at: deleted_at)

        return false unless run_paranoid_callbacks(:after_paranoid_delete, nodes_to_paranoid_delete_ids)
      end
      true
    end
  end

  # Restores a paranoid deleted node and all its descendants, and ensures the
  # appropriate callbacks are executed.
  def paranoid_restore!
    self.class.unscoped do
      raise 'Cannot restore paranoid deleted node if parent is also paranoid deleted!' if parent && parent.deleted_at.present?
    end

    time = Time.now
    nodes_to_paranoid_restore_ids = descendant_including_deleted_ids

    self.class.transaction do
      return false unless run_paranoid_callbacks(:before_paranoid_restore, nodes_to_paranoid_restore_ids)

      self.updated_at = time
      self.deleted_at = nil
      self.class.unscoped.where('id IN (?)', nodes_to_paranoid_restore_ids + [id]).update_all(updated_at: time, deleted_at: nil)

      return false unless run_paranoid_callbacks(:after_paranoid_restore, nodes_to_paranoid_restore_ids)
    end

    true
  end

  # Use this method to retrieve all descendant records, including the ones that have been marked as paranoid deleted
  def descendants_including_deleted
    self.class.unscoped.where(descendant_conditions)
  end

  # Use this method to retrieve all ancestor records, including the ones that have been marked as paranoid deleted
  def ancestors_including_deleted
    self.class.unscoped.where(ancestor_conditions)
  end

  # Use this method to retrieve all descendant record ids, including the ones that have been marked as paranoid deleted
  def descendant_including_deleted_ids
    descendants_including_deleted.pluck(self.class.base_class.primary_key)
  end

  # Use this method to retrieve all ancestor record ids, including the ones that have been marked as paranoid deleted
  def ancestor_including_deleted_ids
    ancestors_including_deleted.pluck(self.class.base_class.primary_key)
  end

  private

  def run_paranoid_callbacks(callback, nodes_to_trigger_content_callbacks_ids)
    self.class.unscoped do
      return false if run_callbacks(callback) == false || self.class.find_paranoid_hidden_content(sub_content_type, content_id).run_callbacks(callback) == false

      self.class.where(id: nodes_to_trigger_content_callbacks_ids).each do |node|
        return false if self.class.find_paranoid_hidden_content(node.sub_content_type, node.content_id).run_callbacks(callback) == false
      end
    end

    true
  end
end
