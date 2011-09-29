module FindAccessible #:nodoc:

  #TODO: reduce duplication in sql
  CONDITIONS = {
          :has_approved_version                            => "(nodes.publishable = :true)",
          :is_published                                    => "(:now >= nodes.publication_start_date AND (nodes.publication_end_date IS NULL OR :now <= nodes.publication_end_date))",
          :is_accessible                                   => "(nodes.hidden = :false OR :user_has_role_on_ancestor = :true OR nodes.id IN (:user_accessible_node_ids))",
          :has_no_hidden_ancestor_or_self                  => "NOT EXISTS ( SELECT * FROM nodes n1 WHERE n1.hidden = :true AND (n1.id = ANY( string_to_array(nodes.ancestry, '/')::integer[] || nodes.id)))",
          :has_no_unpublished_ancestor_or_self             => "NOT EXISTS ( SELECT * FROM nodes n3 WHERE (n3.id = ANY( string_to_array(nodes.ancestry, '/')::integer[]  || nodes.id )) AND (:now < n3.publication_start_date OR (n3.publication_end_date IS NOT NULL AND :now > n3.publication_end_date)))",
          :has_no_hidden_or_unpublished_ancestor_or_self   => "NOT EXISTS ( SELECT * FROM nodes n1 WHERE (n1.id = ANY( string_to_array(nodes.ancestry, '/')::integer[]  || nodes.id )) AND (n1.hidden = :true OR :now < n1.publication_start_date OR (n1.publication_end_date IS NOT NULL AND :now > n1.publication_end_date)))",
          :is_accessible_through_ancestor_or_self_for_user => "EXISTS ( SELECT * FROM role_assignments ra WHERE ra.user_id = :user_id AND ra.node_id = ANY( string_to_array(nodes.ancestry, '/')::integer[]  || nodes.id ))"
  }

  module ClassMethods #:nodoc:
    
    # Find nodes or content with checking of the accessibility for a given user in relation to it's ancestry.
    # _Cannot_ be applied on a named scope!
    # Checks for all aspects that indicate a node should not or should not be shown in public. A node is only included in the results if:
    # * there is an approved version;
    # * this node and all of its ancestors are currently published;
    # * this node and all of its ancestors are _not_ marked as hidden;
    # * if one is, the given user has rights to access this node or one of its parents.
    # 
    # *Options*
    # * +:for+ The user which to check access rights for
    # * +:parent+ Optionally provides a parent to check rights and accessebility against first. Provides a performance increase, does not yet auto-scope!
    # * +:order+ Overrides default ordering by node.position
    # * +:include+ Normal find includes, extended with node if not present and only for content classes
    #
    # Furthermore all default find options are allowed.
    #
    def find_accessible(*args)

      options = args.last.is_a?(Hash) ? args.pop.dup : {}
      user    = options.delete(:for)
      parent  = options.delete(:parent)

      includes = [options.delete(:include)].compact
      # If node is not already in a join or the from clause, we need to make sure it is
      includes << :node unless self==Node || includes.flatten.to_s.include?("node")

      # set the limit to one if we are doing a 'first' find
      limit = options.delete(:limit)
      limit = 1 if args.first == :first

      # order by position from acts_as_list by default
      order = options.delete(:order) 
      order ||= 'nodes.position' if current_scoped_methods.nil? || current_scoped_methods[:find].blank? || current_scoped_methods[:find][:order].blank?
      
      # set the parent node..
      if parent.nil?
        # look for a ancestry and use it to find the parent node
        parent_conditions = merge_conditions((current_scoped_methods[:find][:conditions] rescue {}), options[:conditions])
        parent_conditions = parent_conditions.match(/\(nodes.ancestry \= E\'([0-9\/]+)\'\)/) if parent_conditions.present?
        parent_id         = parent_conditions.to_a.last.split("/").last if parent_conditions.present? && parent_conditions.size == 2
        parent_node       = Node.find(parent_id) if parent_id.present?
      else
        if parent.is_a?(Node)
          parent_node = parent
        else
          parent_node = parent.node
        end
      end

      # set default where options, joined into the acctual conditions
      where_values = {
        :user_accessible_node_ids => (user.is_a?(User) ? user.role_assignments.collect{|ra| ra.node_id } : nil ),
        :user_id                  => (user.is_a?(User) ? user.id : nil),
        :now                      => Time.now.to_s(:db),
        :true                     => true,
        :false                    => false
      }

      if parent_node.nil?
        where_sql = "(#{CONDITIONS[:has_approved_version]}"
        if user.is_a?(User)
          # We have a user, so we need to check the access rights etc.
          where_sql << " AND (#{CONDITIONS[:has_no_hidden_ancestor_or_self]}"
          where_sql << " OR #{CONDITIONS[:is_accessible_through_ancestor_or_self_for_user]}" if user.has_any_role?
          where_sql << ") AND #{CONDITIONS[:has_no_unpublished_ancestor_or_self]})"
        else
          where_sql << " AND #{CONDITIONS[:has_no_hidden_or_unpublished_ancestor_or_self]})"
        end
      elsif parent_node.is_accessible_for?(user)
        # asumes parent scoping conditions are included in conditions already TODO: automate inclusion of parent scoping conditions
        # Should be easy with ancestry.. node.child_conditions?
        where_sql = "(#{CONDITIONS[:is_published]} AND #{CONDITIONS[:is_accessible]} AND #{CONDITIONS[:has_approved_version]})"
        where_values[:user_has_role_on_ancestor] = user.is_a?(User) && user.has_role_on?(RoleAssignment::ALL_ROLES, parent_node)
      else
        # If there is a parent and we can't access it for this user.. we find nothing.
        where_sql = "(1 = 0)"
      end

      new_condition = [where_sql, where_values]

      # wrap any given conditions in brackets or non-approved content will be retrieved after all
      given_conditions = options[:conditions]
      case given_conditions.class.to_s
      when "Array"
        given_conditions[0] = "(#{given_conditions[0]})"
      when "String"
        given_conditions = "(#{given_conditions})"
      end

      conditions = self.merge_conditions(given_conditions, new_condition)

      options.update(:conditions => conditions) if conditions
      options.update(:include    => includes)   if includes
      options.update(:order      => order)      if order
      options.update(:limit      => limit)      if limit

      result = self.find(*(args << options))
    end
  end

  module AssociationExtension #:nodoc:
    # Association extension to be able to use find_accessible on associations
    def find_accessible(*args) #:nodoc:
      options = args.last.is_a?(Hash) ? args.pop : {}

      options.reverse_merge!(
        :group   => proxy_reflection.options[:group],
        :limit   => proxy_reflection.options[:limit],
        :offset  => proxy_reflection.options[:offset],
        :order   => proxy_reflection.options[:order],
        :joins   => proxy_reflection.options[:joins],
        :include => proxy_reflection.options[:include],
        :select  => proxy_reflection.options[:select]
      )
      
      # add the parent scope
      new_condition = ["#{proxy_reflection.primary_key_name} = ? ", proxy_owner.quoted_id]
      options.update(:conditions => proxy_reflection.klass.merge_conditions(options[:conditions], new_condition))
      options[:parent] = proxy_owner

      proxy_reflection.klass.find_accessible(*(args << options))
    end
  end
end
