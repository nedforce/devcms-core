module NodeExtensions::VisibilityAndAccessibility
  extend ActiveSupport::Concern

  included do
    validates_inclusion_of :private, in: [false, true], allow_nil: false
    validates_inclusion_of :hidden,  in: [false, true], allow_nil: false

    scope :accessible, ->{ where('nodes.hidden = false AND nodes.publishable = true AND (:now >= nodes.publication_start_date AND (nodes.publication_end_date IS NULL OR :now <= nodes.publication_end_date))', now: Time.now) }
    scope :is_public,  ->{ where('nodes.private' => false) }
    scope :is_private, ->{ where('nodes.private' => true) }
  end

  def public?
    !self.private?
  end

  def is_private_or_has_private_ancestor?
    self_and_ancestors.where(private: true).exists?
  end

  def has_private_ancestor?
    ancestors.where(private: true).exists?
  end

  def has_hidden_ancestor?
    ancestors.where(hidden: true).exists?
  end

  def top_level_private_ancestor
    self_and_ancestors.is_private.first
  end

  def accessible_for_user?(user = nil)
    if self_and_ancestors.sections.is_private.any?
      user && user.role_assignments.where(node_id: self_and_ancestor_ids).exists?
    else
      true
    end
  end

  def set_accessibility!(accessible)
    if !(content_class <= Section)
      errors.add(:base, I18n.t('activerecord.errors.models.node.attributes.base.can_only_set_accessibility_on_sections'))
      false
    elsif is_global_frontpage? || contains_global_frontpage?
      errors.add(:base, I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_public_when_it_has_a_private_ancestor'))
      false
    elsif !accessible
      update_attribute(:private, true) unless private? || has_private_ancestor?
      true
    elsif has_private_ancestor?
      errors.add(:base, I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_public_when_it_has_a_private_ancestor'))
      false
    elsif private?
      update_attribute(:private, false)
      true
    else
      true
    end
  rescue
    errors.add(:base, I18n.t('activerecord.errors.models.node.attributes.base.set_accessibility_failed'))
    false
  end

  def set_visibility!(visible)
    if is_global_frontpage? || contains_global_frontpage?
      errors.add(:base, I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_public_when_it_has_a_private_ancestor'))
      false
    elsif !visible
      Node.where(subtree_conditions).update_all(hidden: true) unless hidden?
      self.hidden = true
      true
    elsif has_hidden_ancestor?
      errors.add(:base, I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_visible_when_it_has_a_hidden_ancestor'))
      false
    else
      Node.where(subtree_conditions).update_all(hidden: false) if hidden?
      self.hidden = false
      true
    end
  rescue
    errors.add(I18n.t('activerecord.errors.models.node.attributes.base.set_visibility_failed'))
    false
  end
end
