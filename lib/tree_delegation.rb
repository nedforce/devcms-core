# This module delegates to both ancestry and acts_a_list to emulate
# the functionality of awesome_nested_set. Redundant methods calling
# only +super+ serve a self-documenting function. +super+ calls previously
# included methods provided by ancestry or acts_a_list.
module TreeDelegation
  def self.included(base)
    base.class_eval do
      acts_as_tree

      sortable :scope => :ancestry

      named_scope :sorted_by_position, :order => :position
      named_scope :hidden, :conditions => {:hidden => true}
      
      validates_presence_of :parent, :unless => lambda {|n| Node.count.zero? || (Node.root && Node.root == n ) }
            
      # validates_numericality_of :position, :greater_than => 0, :only => :update
      
      #alidates_associated :content
      validate :parent_should_allow_type
      
      include InstanceMethods
      extend ClassMethods
    end
  end
  
  module InstanceMethods
    def parent_id
      super
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
      path
    end

    # Returns an array of all parents
    def ancestors(*args)
      super
    end

    def is_hidden?
      hidden? or has_hidden_ancestor?
    end

    def has_hidden_ancestor?
      ancestors.hidden.any?
    end

    # Returns the array of all children of the parent, except self
    def siblings
      super
    end

    # Returns a set of itself and all of its nested children
    def self_and_descendants
      subtree
    end

    # Returns a set of all of its children and nested children
    def descendants(*args)
      super
    end

    # Returns a set of only this entry's immediate children
    def children
      super.sorted_by_position
    end

    def is_descendant_of?(other)
      ancestors.include?(other)
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
      raise ActiveRecord::ActiveRecordError, "You cannot move a new node" if self.new_record?

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
          insert_at!(target.position + 1)
        when :child
          move_to_bottom!
        end
      else
        raise ActiveRecord::ActiveRecordError, "Move failed: #{self.errors.full_messages.pretty_inspect}"
      end
    end
    
    # Reorders the nodes children by the order the of their ids given
    def reorder_children(*ids)
      transaction do
        ordered_ids = ids.flatten.uniq
        ordered_ids.each do |child_id|
          position = ordered_ids.index(child_id) + 1
          children.find(child_id).insert_at!(position)
        end
      end
    end
    
    # checks wether the content type is valid as a child of the parent
    def parent_should_allow_type
      unless self.parent.nil? || content.own_content_class.valid_parent_class?(self.parent.content_class)
        errors.add_to_base "'#{self.parent.content_class.human_name}' #{I18n.t('tree_delegation.doesnt_accept')} '#{content.own_content_class.human_name}' #{:type}."
      end
    end
  end

  module ClassMethods
    def root
      super
    end
  end
end

