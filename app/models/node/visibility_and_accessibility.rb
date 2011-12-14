module Node::VisibilityAndAccessibility
  
  def self.included(base)
    base.validates_inclusion_of :private, :in => [ false, true ], :allow_nil => false
    
    base.validates_inclusion_of :hidden,  :in => [ false, true ], :allow_nil => false
    
    # Do not allow these fields to be set by mass assignments, to prevent mishaps.
    # See the set_visibility! and set_accessibility! methods instead.
    base.attr_protected :hidden, :private
    
    base.named_scope :accessible, (lambda do 
      { 
        :conditions => [ 
          'nodes.hidden = false AND nodes.publishable = true AND (:now >= nodes.publication_start_date AND (nodes.publication_end_date IS NULL OR :now <= nodes.publication_end_date))', 
          { :now => Time.now.to_s(:db) } 
        ] 
      }
    end)

    base.named_scope :public, { :conditions => { 'nodes.private' => false } }

    base.named_scope :private, { :conditions => { 'nodes.private' => true } }
  end
  
  def has_private_ancestor?
    self.ancestors.exists?(:private => true)
  end
  
  def has_hidden_ancestor?
    self.ancestors.exists?(:hidden => true)
  end
  
  def top_level_private_ancestor
    self.self_and_ancestors.private.first
  end
  
  def accessible_for_user?(user = nil)
    if self.self_and_ancestors.sections.private.any?
      user && user.role_assignments.exists?(:node_id => self.self_and_ancestor_ids)
    else
      true
    end
  end
  
  def set_accessibility!(accessible)
    if !(self.content_class <= Section)
      self.errors.add_to_base(I18n.t('activerecord.errors.models.node.attributes.base.can_only_set_accessibility_on_sections'))
      false
    elsif self.is_global_frontpage? || self.contains_global_frontpage?
      self.errors.add_to_base(I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_public_when_it_has_a_private_ancestor'))
      false
    else
      if !accessible
        self.update_attribute(:private, true) unless self.private? || self.has_private_ancestor?
        true
      elsif self.has_private_ancestor?
        self.errors.add_to_base(I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_public_when_it_has_a_private_ancestor'))
        false
      else
        self.update_attribute(:private, false) if self.private?
        true
      end
    end
  rescue Exception
    self.errors.add_to_base(I18n.t('activerecord.errors.models.node.attributes.base.set_accessibility_failed'))
    false
  end

  def set_visibility!(visible)
    if self.is_global_frontpage? || self.contains_global_frontpage?
      self.errors.add_to_base(I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_public_when_it_has_a_private_ancestor'))
      false
    else
      if !visible
        Node.update_all('hidden = true', self.subtree_conditions) unless self.hidden?
        self.hidden = true   
        true
      elsif self.has_hidden_ancestor?
        self.errors.add_to_base(I18n.t('activerecord.errors.models.node.attributes.base.cant_make_node_visible_when_it_has_a_hidden_ancestor'))
        false
      else
        Node.update_all('hidden = false', self.subtree_conditions) if self.hidden?
        self.hidden = false
        true
      end
    end
  rescue
    self.errors.add(I18n.t('activerecord.errors.models.node.attributes.base.set_visibility_failed'))
    false
  end
  
end