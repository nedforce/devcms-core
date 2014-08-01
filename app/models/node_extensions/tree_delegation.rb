module NodeExtensions::TreeDelegation
  extend ActiveSupport::Concern   

  included do
    has_ancestry :cache_depth => true
    # sortable :scope => :ancestry
    acts_as_list :scope => :ancestry

    validate :parent_should_be_valid, :unless => lambda { |n| Node.count.zero? || (Node.root && Node.root == n) }
    validate :parent_should_allow_type

    scope :broken_list_ancestries, select(:ancestry).group(:ancestry).having('max(nodes.position)!=(SELECT COUNT(*) FROM nodes n2 WHERE n2.ancestry=nodes.ancestry AND deleted_at IS NULL) OR sum(nodes.position)!=(SELECT SUM(DISTINCT position) FROM nodes n3 WHERE n3.ancestry=nodes.ancestry AND deleted_at IS NULL)').reorder(:ancestry)

    def will_leave_list?
      in_list? && parent_id_changed?
    end

    def in_list?
      !(ancestry_callbacks_disabled? || !super)
    end
  end

  module ClassMethods
    def root
      super
    end

    def exclude_subtrees_conditions_for(nodes = nil)
      nodes = Array(nodes)

      return { :conditions => {} } unless nodes.present?

      sql = ''
      values = {}

      node_ids = nodes.map { |n| n.id }
      node_child_ancestries = nodes.map { |n| n.child_ancestry }

      sql += "nodes.id NOT IN (:node_ids) AND nodes.ancestry NOT IN (:node_child_ancestries)"
      values.update(:node_ids => node_ids, :node_child_ancestries => node_child_ancestries)

      node_child_ancestries.each_with_index do |child_ancestry, index|
        symbol = :"node_child_ancestry_#{index}"

        sql += " AND nodes.ancestry NOT LIKE :#{symbol}"
        values.update(symbol => "#{child_ancestry}/%")
      end

      sql += ' OR nodes.ancestry IS NULL'

      { :conditions => [ sql, values ] }
    end
  end

  def parent_id
    super
  end

  def parent_id_was
    ancestry_was ? ancestry_was.split('/').last : nil
  end

  def parent_id_changed?
    parent_id_was != parent_id.to_s
  end

  # Determines which nodes from the given set of nodes can be reached from the current node.
  # Returns the tree that can be constructed from the given nodes and which is rooted at the current node.
  # Respects the order of the nodes given.
  def closure_for(nodes = [])
    tree = ActiveSupport::OrderedHash.new
    tree[self] = self.calculate_closure_for(nodes).first
    tree
  end

  # Returns true if this is a root node.
  def root?
    is_root?
  end

  def leaf?
    is_childless?
  end

  # Returns root
  def root
    super
  end

  # Returns the immediate parent
  def parent
    super
  end

  # Returns the array of all parents and self
  def self_and_ancestors
    self.path
  end

  def self_and_ancestor_ids
    self.path_ids
  end

  def self_and_children
    base_class = self.base_class
    table_name = base_class.table_name

    base_class.scoped :conditions => [
      "#{table_name}.#{base_class.primary_key} = :own_id OR #{table_name}.#{base_class.ancestry_column} = :child_ancestry", 
      {
        :own_id => self.send(base_class.primary_key),
        :child_ancestry => self.child_ancestry
      }
    ]
  end

  # Returns an array of all parents
  def ancestors(*args)
    super
  end

  # Returns the array of all children of the parent, except self
  def siblings
    super
  end

  # Returns a set of itself and all of its nested children
  def self_and_descendants(*args)
    self.subtree(*args)
  end

  # Returns a set of only this entry's immediate children
  def children
    super.sorted_by_position
  end

  def is_descendant_of?(other)
    self.ancestors.include?(other)
  end

  # Find the first sibling to the left
  def left_sibling
    previous_item
  end

  # Find the first sibling to the right
  def right_sibling
    next_item
  end

  # Shorthand method for finding the left sibling and moving to the left of it.
  def move_left
    move_up!
  end

  # Shorthand method for finding the right sibling and moving to the right of it.
  def move_right
    move_down!
  end

  # Move the node to the left of another node (you can pass id only)
  def move_to_left_of(node)
    move_to_bottom
    move_to node, :left
  end

  # Move the node to the left of another node (you can pass id only)
  def move_to_right_of(node)
    move_to node, :right
  end

  # Move the node to the child of another node (you can pass id only)
  def move_to_child_of(node)
    move_to node, :child
  end

  # Move node to left, right or child of target node
  def move_to(target, position)
    raise ActiveRecord::ActiveRecordError, 'You cannot move a new node' if self.new_record?

    transaction do
      if position == :child
        self.parent = target
      else
        self.parent = target.parent
      end

      if save
        case position
        when :left
          insert_at!(target.position)
        when :right
          insert_at!(target.position + 1 )
        end
      else
        raise ActiveRecord::ActiveRecordError, "Move failed: #{self.errors.full_messages.pretty_inspect}"
      end
      update_attributes :updated_at => Time.now
    end
  end

  # Reorders the nodes children by the order the of their ids given
  def reorder_children(*ids)
    if children.present?
      ids = children.map(&:id) if ids.blank?
      transaction do
        ordered_ids = ids.flatten.uniq
        ordered_ids.each do |child_id|
          position = ordered_ids.index(child_id) + 1
          self.class.update_all({ :position => position }, { :id => child_id })
        end
      end
    end
  end

  # checks whether the content type is valid as a child of the parent
  def parent_should_allow_type
    unless self.parent.nil? || self.content_class.valid_parent_class?(self.parent.content_class)
      self.errors.add :base, "'#{self.parent.content_class.human_name}' #{I18n.t('tree_delegation.doesnt_accept')} '#{self.content_class.human_name}' #{:type}."
    end
  end

  def parent_should_be_valid
    if self.parent.blank?
      self.errors.add(:base, I18n.t('node.parent_invalid'))
    end
  end

  def path_child_ancestries
    path_ids.enum_for(:each_with_index).map { |item, index| path_ids[0..(path_ids.length - index - 1)] }.map { |result| result.join('/') }
  end

  def path_children_by_depth
    Node.path_children_by_depth(self)
  end

  def move_down!
    move_lower
  end

  def move_up!
    move_higher
  end

  def move_to_bottom!
    move_to_bottom
  end

  def insert_at! position
    insert_at position
  end

  def last_item?
    last?
  end

  protected

  def add_descendants_to_list
    descendants.where('position IS NULL').each do |descendant|
      descendant.add_to_list
    end
  end

  def calculate_closure_for(nodes)
    children, rest = nodes.partition { |n| n.ancestry == self.child_ancestry }

    tree = children.inject(ActiveSupport::OrderedHash.new) do |subtree, child|
      subtree[child], rest = child.calculate_closure_for(rest)
      subtree
    end

    [tree, rest]
  end
end
