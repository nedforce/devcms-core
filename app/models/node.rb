require 'iconv'

# A node is a proxy for different types of content, so that all types of
# content may be managed in a uniform manner. A node cannot be instantiated
# directly, instead one will be automatically created when the associated
# content node is saved.
#
# For example, pages and weblogs are two different types of content, yet both
# should be referrable as an URL and linkable in a menu. Because both types
# of content are encapsulated through a node, they may now be managed without
# regard of their content type details.
#
# <b>Content nodes</b>
#
# The object containing the content is referred to as the <em>content node</em>.
# Objects may gain the appropriate behavior by specifying +acts_as_content_node+
# from Acts::ContentNode::ClassMethods.
#
# <b>Bijective relationship</b>
#
# The association between a node and its content node is bijective: each content
# node should be represented by exactly one unique node at all times. This node
# should be created when the content node is. To maintain referential integrity
# the associated node should never be changed afterwards.
#
# As a consequence of this bijection, when either a node or content node is
# destroyed, its associated counterpart needs to be destroyed as well.
#
# <b>URL aliases</b>
#
# A node can have an URL alias which uniquely identifies it.
#
# <b>Taxonomy</b>
#
# Nodes are ordered in a tree structure using a nested set. This represents
# the website's taxonomy of content nodes and is implemented using AwesomeNestedSet.
# Content node types can have certain constraints applied to it regarding its accepting
# types (i.e. content node types of which content nodes are accepted as children),
# and whether it is insertable in content nodes of any type (default) or not.
# See +acts_as_content_node+ for more information on how to do this.
#
# <b>Content type register</b>
#
# The Node class also houses the content type register. If a new content type is to be implemented
# do not forget to add it to the array returned by +Node#content_types+.
#
# *Specification*
#
# Attributes
#
# * +content+ - The associated content node.
# * +layout+  - The layout, this maybe nil.
# * +layout_variant+  - The layout variant, this maybe nil.
# * +layout_configuration+  - Serialized hash of additional options to be used by the layout, this maybe nil.
# * +url_alias+ - An URL alias for this node.
# * +commentable+ - True if a node can be commented on, else false.
# * +content_box_title+ - The title of the content box representation of this node (see SideboxElement).
# * +content_box_icon+ - The icon of the content box representation of this node.
# * +content_box_colour+ - The colour of the content box representation of this node.
# * +content_box_number_of_items+ - The number of items of the content box representation of this node.
# * +exprires_on+ - The date after which this node should no longer be considered up-to-date.
#
# Preconditions
#
# * Requires the presence of +content+.
# * Requires the uniqueness of +content+.
# * Requires the uniqueness of +url_alias+ if not blank.
# * Requires a properly formatted +url_alias+ if not blank.
# * Requires +url_alias+ to not contain any reserved words if not blank.
# * Requires !is_global_frontpage? && !contains_global_frontpage? to hide.
# * Requires +external_id+ to be unique with in the scope of its parent. Allows nil.
#
# Postconditions
#
# * The content node will be destroyed before this node is.
#
class Node < ActiveRecord::Base
  # Delegate tree calls to use Ancestry. Ensure this is added *after* other before/after filters.
  include TreeDelegation
  
  include ERB::Util # Provides html_escape()
  
  # Load expiration functionality
  include Node::Expiration
  
  # Load layout & template functionality
  include Node::Layouting
  
  # It seems serialize has broken...
  def layout_configuration
    self.attributes["layout_configuration"] || {}
  end
    
  # Load Url Aliasing functionality
  include Node::UrlAliasing
  alias_method_chain :move_to, :update_url_aliases
  
  self.extend FindAccessible::ClassMethods

  if SETTLER_LOADED && DevCMS.search_configuration[:enabled_search_engines].include?('ferret')
    self.extend Search::Modules::Ferret::FerretNodeExtension
    acts_as_searchable
  end

  INDEX_DATETIME_FORMAT = "%Y%m%d%H%M"

  attr_protected :hits

  has_many :node_categories, :dependent => :destroy
  has_many :categories, :through => :node_categories

  belongs_to :content, :polymorphic => true
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'
  belongs_to :responsible_user, :class_name => 'User'

  has_many :links,            :dependent => :destroy, :class_name => 'InternalLink', :foreign_key => :linked_node_id
  has_many :copies,           :dependent => :destroy, :class_name => 'ContentCopy',  :foreign_key => :copied_node_id
  has_many :role_assignments, :dependent => :destroy

  has_many :abbreviations, :dependent => :destroy
  has_many :synonyms,      :dependent => :destroy

  # See the preconditions overview for an explanation of these validations.
  validate :should_not_be_directly_instantiated
  validates_presence_of   :content
  validates_uniqueness_of :content_id, :scope => :content_type

  validates_inclusion_of :commentable,       :in => [ false, true ], :allow_nil => true
  validates_inclusion_of :hide_right_column, :in => [ false, true ], :allow_nil => true
  
  # Prevents the root +Node+ from being destroyed.
  before_destroy :prevent_root_destruction

  # A private copy of the original destroy method that is used for overloading.
  alias_method :original_destroy, :destroy

  # Create a scope for only finding approved nodes.
  named_scope :approved,   :conditions => { :status => 'approved' }
  named_scope :unapproved, :conditions => [ "status = ? OR status = ?", "unapproved", "rejected" ], :order => "updated_at DESC"

  # After update to hidden reindex all children
  before_update { |node| @hidden_changed = node.hidden_changed?; true}
  after_update { |node| node.reindex_self_and_children if @hidden_changed; true }

  after_save :save_category_attributes

  attr_accessor :category_attributes
  
  # Nodes are taggable with alterative titles
  acts_as_taggable_on :title_alternatives

  # Keep state of nodes made or updated by editors
  #
  #                       reject
  #                       (admin,final_editor)
  #               '----------------------------> rejected -'
  #               |                              |         |
  # create        |                    approve   |         |
  # (editor)      |        (admin,final_editor)  v         |
  # ---------> unapproved ---------------------> approved--|
  #               ^                                        |
  #               '----------------------------------------'
  #                       wait_for_approval (editor)
  #
  # draft              wait_for_approval (editor)
  # ---------> drafted ---------------------------> unapproved
  #             | ^                                      |
  #    approve  | '--------------------------------------'
  #             |          draft
  #             v
  #           approved
  acts_as_state_machine :initial => :approved, :column => 'status'

  # A node is commentable
  acts_as_commentable

  state :unapproved
  state :approved
  state :rejected
  state :drafted

  event :draft do
    transitions :from => :approved,   :to => :drafted
    transitions :from => :unapproved, :to => :drafted
  end

  event :wait_for_approval do
    transitions :from => :drafted,  :to => :unapproved
    transitions :from => :approved, :to => :unapproved
    transitions :from => :rejected, :to => :unapproved
  end

  event :reject do
    transitions :from => :unapproved, :to => :rejected
  end

  event :approve do
    transitions :from => :drafted,    :to => :approved
    transitions :from => :unapproved, :to => :approved
    transitions :from => :rejected,   :to => :approved
  end

  # Immediately reindex this node after it has been approved.
  # Also, create a new current version
  def approve_with_reindexing_and_versioning!
    self.approve_without_reindexing_and_versioning!
    self.update_search_index
  end

  alias_method_chain :approve!, :reindexing_and_versioning

  def move_to_with_reindexing(*args)
    self.move_to_without_reindexing(*args)
    self.reindex_self_and_children
  end
  
  alias_method_chain :move_to, :reindexing

  # A proxy method for accessing the SanitizeHelper through the Helper class.
  def help
    Helper.instance
  end

  # The Helper class includes the SanitizeHelper for proxy access.
  class Helper
    include Singleton
    include ActionView::Helpers::SanitizeHelper
    extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  end

  # Returns true if this node has no children
  def leaf?
    # don't expand for PDC nodes from an external source
    return true if content_class.name == 'ProductCatalogue' && content.opus_plus_importer
    super
  end

  # Destroys this node and its associated content node.
  #
  # The destruction of self is delegated to the content node through its
  # <tt>before_destroy</tt> callback method.
  #
  # *Arguments*
  #
  # [options] Options hash.
  #
  # *Options*
  #
  # [:destroy_content_node] WARNING: For internal use only and it should *not* be set to _false_ manually.
  #                         We have to take care to prevent infinite recursion because the content
  #                         node will call node.destroy (i.e. this method) again to destroy us.
  #                         Therefore the destroy_content_node option is introduced, which will be
  #                         set to false when node.destroy is called from the content node.
  def destroy(options = {:destroy_content_node => true})
    if options[:destroy_content_node] && content
      begin
        destroyed_content = content.destroy # Content will on its turn call node.destroy again.
      rescue NoMethodError => e
        # ContentCopy and InternalLink nodes are destroyed when their associated copied/linked node is destroyed.
        # This will cause problems when an ancestor of these nodes is destroyed, resulting in a double
        # destruction of the ContentCopy or InternalLink node. This nasty hack here prevents that.
        case self.content_class
          when ContentCopy
            raise e if ContentCopy.exists?(self.id)
          when InternalLink
            raise e if InternalLink.exists?(self.id)
          else
            raise e # Re-raise e as it's an unrelated error
        end
      end
      destroyed_content.nil? ? nil : self
    else
      without_search_reindex{ self.original_destroy } # Disable ferret updates (ferret_destroy is executed anyway)
    end
  end
  
  def self.content_to_hide_from_menu
    @content_to_hide_from_menu ||= @content_types_configuration.select do |content_type, configuration|
      !configuration[:show_in_menu]
    end.map(&:first)
  end
  
  # Content type configuration concerns
  # Register ContentType and fonfiguration, merge with overrides in DevCMS if they exist
  def self.register_content_type(type, configuration)
    @content_types_configuration ||= {}
    name = type.is_a?(String) ? type : type.name
    @content_types_configuration[name] = configuration.merge(DevCMS.content_types_configuration[name] || {})
  end
  
  def self.content_types_configuration
    @content_types_configuration
  end
  
  def self.content_type_configuration(class_name)
    class_exists?(class_name, :constantize => true) ? @content_types_configuration[class_name] : {}
  end
  
  def content_type_configuration 
    Node.content_type_configuration(self.content_class.to_s)
  end

  # Returns a hash representing this node's config properties for an Ext.dvtr.AsyncTreeNode javascript object.
  # Note: Convert to JSON before usage in Javascript.
  def to_tree_node_for(user, options = {})
    active_node = options[:expand_if_ancestor_of]

    role      = user.role_on(self)
    role_name = role.nil? ? '' : role.name

    user_is_admin        = user.has_role_on?('admin',        self)
    user_is_final_editor = user.has_role_on?('final_editor', self)
    user_is_editor       = user.has_role_on?('editor',       self)

    # Build the hash (Please use JS naming conventions for keys (camelCased)):
    hash = {
      # default Ext attributes:
      :id            => self.id,
      :text          => self.tree_text,
      :leaf          => !self.is_expandable_for_user?(user),
      :noChildNodes  => self.leaf?,
      :disabled      => role.nil?,
      :iconCls       => self.content.tree_icon_class,
      :allowDrag     => (user_is_final_editor or user_is_admin or user_is_editor),
      :allowChildren => (user_is_final_editor or user_is_admin),
      :expanded      => active_node && active_node.ancestry.present? ? active_node.ancestry.starts_with?(self.child_ancestry) : false,
      # Admins can't create weblogs or weblog posts through the admin interface
      :creatableChildContentTypes => self.content_type_configuration[:allowed_child_content_types].inject([]) do |array, content_type|
        child_content_type_configuration = Node.content_type_configuration(content_type)

        if (klass = class_exists?(content_type, :constantize => true)) && child_content_type_configuration[:enabled] && child_content_type_configuration[:allowed_roles_for_create].include?(role_name)
          array << {
            :text           => klass.human_name,
            :modelName      => content_type,
            :controllerName => "/admin/#{child_content_type_configuration[:controller_name] || klass.table_name}"
          } unless self.content_class == Site && klass == Site && !self.root? # Prevent nesting of sites deeper than 1
        end

        array
      end.sort_by { |hash| hash[:text] },
      :allowedChildContentTypes        => content_type_configuration[:allowed_child_content_types],
      :ownContentType                  => self.content_class == ContentCopy ? self.content.copied_node.content_class.to_s : self.content_class.to_s,
      :allowEdit                       => content_type_configuration[:allowed_roles_for_update].include?(role_name),
      :controllerName                  => "/admin/#{content_type_configuration[:controller_name] || self.content_class.table_name}",
      :parentNodeId                    => self.parent_id,
      :parentURLAlias                  => self.parent_url_alias,
      :customURLSuffix                 => self.custom_url_suffix.present? ? self.custom_url_suffix : nil,
      :customURLAlias                  => self.custom_url_alias.present? ? self.custom_url_alias : nil,
      :URLAlias                        => self.url_alias.present? ? self.url_alias : nil,
      :contentNodeId                   => self.content_id,
      :siteNodeId                      => self.containing_site.id,
      :userRole                        => role ? role_name : nil,
      :undeletable                     => self.root? || !content_type_configuration[:allowed_roles_for_destroy].include?(role_name) || (!user_is_admin && self.content_class == Image && self.content.is_for_header?),
      :allowGlobalFrontpageSetting     => user_is_admin,
      :isContentCopy                   => self.content_class == ContentCopy,
      :isFrontpage                     => self.is_frontpage?,
      :isGlobalFrontpage               => self.is_global_frontpage?,
      :isRepeatingCalendarItem         => self.content_class <= CalendarItem && self.content.has_repetitions?,
      :containsGlobalFrontpage         => self.contains_global_frontpage?,
      :allowTogglePrivate              => user_is_final_editor || user_is_admin,
      :isPrivate                       => self.hidden?,
      :showInMenu                      => self.show_in_menu,
      :hasChangedFeed                  => self.has_changed_feed,
      :allowToggleChangedFeed          => content_type_configuration[:has_own_feed] || [ Feed, Section, Site ].include?(self.content_class),
      :hasPrivateAncestor              => self.has_hidden_ancestor?,
      :allowUrlAliasSetting            => user_is_final_editor || user_is_admin,
      :allowContentCopyCreation        => !self.root? && content_type_configuration[:copyable],
      :isRoot                          => self.root?,
      :treeLoaderName                  => content_type_configuration[:tree_loader_name],
      :allowLayoutConfig               => user_is_admin || user_is_final_editor,
      :allowRoleAssignment             => RoleAssignment::ALLOWED_TYPES.include?(self.content_class.to_s),
      :numberChildren                  => self.content_class == Meeting,
      :allowSortChildren               => (user_is_admin || user_is_final_editor) && content_type_configuration[:children_can_be_sorted],
      :childCount                      => self.children.count,
      :hasImport                       => content_type_configuration[:has_import],
      :hasSync                         => content_type_configuration[:has_sync],
      :hasEditItems                    => content_type_configuration[:has_edit_items],
      :availableContentRepresentations => content_type_configuration[:available_content_representations]
    }

    hash.merge(DevCMS.tree_node_for(self, user, options))
  end

  # Checks whether the node is expandable (in the admin view) for the given user.
  # A node is expandable if the user has a role on the node itself or one of its descendants.
  def is_expandable_for_user?(user)
    user.role_on(self) || user.role_assignments.first(:joins => :node, :conditions => self.descendant_conditions )
  end

  # Returns the text that should be displayed in the node tree
  def tree_text
    tree_text = html_escape(self.content.tree_text(self))

    # TODO This should be handled by the JS class Ext.treehouse.AsyncContentTreeNode
    if !self.approved?
      tree_text += " <i>("
      if self.drafted?
        tree_text += I18n.t('nodes.draft')
      elsif self.rejected?
        tree_text += I18n.t('nodes.rejected')
      elsif self.unapproved?
        tree_text += I18n.t('nodes.unapproved')
      end
      tree_text += ")</i>"
    end

    tree_text
  end

  # Returns the site that directly contains this node as a descendant
  def containing_site
    @containing_site ||= if self.depth > 0 && self.self_and_ancestors[1].content.is_a?(Site)
      self.self_and_ancestors[1]
    else
      Node.root
    end
  end
  
  # Returns true if this node should be hidden from the menu, false otherwise.
  def hidden_from_menu?
    !self.content_type_configuration[:show_in_menu] || !self.show_in_menu || self.is_hidden?
  end

  # Returns true if this node should be visible to the given +user+, false otherwise.
  def visible_for_user?(user = nil)
    (user.is_a?(User) && user.has_role_on?(RoleAssignment::ALL_ROLES, self)) || !self.is_hidden?
  end

  # Returns true if this node is published, false otherwise.
  def published?
    now = Time.now
    
    self.publication_start_date <= now && (self.publication_end_date.blank? || self.publication_end_date >= now)
  end

  # Returns true if this node is accessible for the given +user+, false otherwise.
  def is_accessible_for?(user = nil)
    Node.find_accessible(:first, :for => user, :conditions => ['nodes.id = ?', self.id]) == self
  end

  # Returns the children nodes of this node that are accessible, for the given +options+.
  def accessible_children(options = {})
    sql_where      = "nodes.ancestry = ?"
    for_menu       = options.delete(:for_menu)
    excluded_types = [options.delete(:exclude_content_type)].flatten.compact
    sql_where << " AND NOT nodes.content_type IN (?)" if for_menu.present? || excluded_types.present?
    conditions     = nil
    arguments      = [ self.child_ancestry ]

    if for_menu
      sql_where << " AND nodes.show_in_menu = ?"
      arguments << (Node.content_to_hide_from_menu + excluded_types).uniq
      arguments << true
      conditions = [ sql_where ] + arguments
    else
      arguments << excluded_types unless excluded_types.blank?
      conditions = [ sql_where ] + arguments
    end

    conditions = Node.merge_conditions(conditions, options[:conditions]) if options[:conditions]
    Node.find_accessible(:all, options.merge({:conditions => conditions, :parent => self}))
  end

  # Returns the children content nodes of this node that are accessible, for the given +options+.
  def accessible_content_children(options = {})
    accessible_children(options).map { |child| child.approved_content(:allow_nil => true) }.compact
  end
  
  # Override to return the descendant ancestry with table name prepended
  def descendant_conditions
    ["nodes.ancestry like ? or nodes.ancestry = ?", "#{child_ancestry}/%", child_ancestry]
  end  

  # Returns the latest approved content for this node. If nothing has been
  # approved yet, then raise an ActiveRecord::RecordNotFound exception to
  # render a 404. You can suppress the exception by setting :allow_nil => true
  # in which case nil may be returned.
  def approved_content(options = { :allow_nil => false })
    content = (self.approvable? ? self.content.approved_version : self.content)

    raise ActiveRecord::RecordNotFound if content.nil? && !options[:allow_nil]
    content
  end

  # Returns true if this node is versioned, false otherwise.
  def approvable?
    content.respond_to?(:is_versioned?)
  end

  def set_approval_state_for_user(user, skip_approval = false)
    # Update the edited_by field.
    self.update_attribute(:edited_by, user.id) unless skip_approval

    if user.has_role_on?(['admin', 'final_editor'], self) && !skip_approval
      self.approve!
    else
      self.wait_for_approval!
    end
  end

  # Increments the hits counter without updating the updated_at value.
  # This implementation does not affect the +updated_at+ field.
  def increment_hits!
    Node.without_search_reindex do # No update of the search index is necessary.
      # +increment!(:hits)+ first reads from the db, and then updates allowing for
      # stale number of hits on concurrent executions. Using a single SQL statement instead:
      connection.update("UPDATE nodes SET hits = hits + 1 WHERE id = #{self.id}")
    end
  end

  # See :increment_hits! Same construct, but now for removing a percentage of the hits.
  def self.reduce_hit_count(factor = 0.9)
    Node.without_search_reindex do
      connection.update("UPDATE nodes SET hits = hits * #{1 - factor}")
    end
  end

  def last_changes(on, options = {})
    conditions = options.delete(:conditions) || ""
    
    if on == :all
      # Filter on actual content
      conditions = Node.merge_conditions(conditions, "nodes.content_type IN ('Page', 'Section', 'NewsItem')")
      # Scope on descendants
      desc_conds    = self.descendant_conditions
      desc_conds[0] = "(#{desc_conds.first})" # Ensure the conditions are evaluated in the right order.
      conditions    = Node.merge_conditions(conditions, desc_conds)
      if self.root? # Exclude other sites if this is the root node
        sql    = []
        values = []
        Site.all(:include => :node, :conditions => ["nodes.id != ?", self.id]).each do |site|
          site_conds = site.node.descendant_conditions
          sql       << site_conds.shift
          sql       << "nodes.id = ?"
          values    += site_conds
          values    << site.node.id
        end
        if sql.present?
          conditions = Node.merge_conditions(conditions, ["NOT (#{sql.join(' OR ')})"] + values)
        end
      end
      conditions << Node.send(:sanitize_sql, [" OR nodes.id = ?", self.id]) # Include self
    elsif on == :self
      conditions = Node.merge_conditions(conditions, ["nodes.id = ?", self.id])
      options[:parent] = self
    end

    defaults = {
      :joins => "LEFT JOIN versions ON versionable_id = nodes.content_id AND versionable_type = nodes.content_type",
      :order => 'COALESCE(versions.created_at, nodes.updated_at) DESC'
    }

    options[:conditions] = conditions
    results = Node.find_accessible(:all, options.merge(defaults))
  end

  def reindex_self_and_children
    if self.respond_to?(:update_index)
      self.self_and_descendants.each do |node|
        node.update_search_index
      end
    end
  end

  def disable_search_reindex_until_saved
    self.disable_reindex_until_saved if self.respond_to?(:disable_reindex_until_saved)
  end

  def add_to_search_index
    self.add_to_index if self.respond_to?(:add_to_index)
  end

  def update_search_index
    self.update_index if self.respond_to?(:update_index)
  end

  def without_search_reindex(&block)
    if self.respond_to?(:without_reindex)
      self.without_reindex &block
    else
      yield
    end
  end

  def self.without_search_reindex(&block)
    if self.respond_to?(:without_reindex)
      Node.without_reindex &block
    else
      yield
    end
  end

  # Sort a node's children by title or creation_date, ascending or descending.
  # Note that this a SQL-heavy operation (many queries), might need to find
  # another way to implement this.
  #
  # *options*
  #
  # [:sort_by]   (Symbol) Property to sort by, e.g. :content_title or :created_at. (Defaults to :content_title.)
  # [:order]     (String) Either 'desc' for descending order or 'asc' for ascending order. (Defaults to 'asc'.)
  def sort_children(options = {})
    options = { :sort_by => :content_title, :order => 'asc' }.merge(options)

    # sort in memory
    sorted_children = self.children.sort do |c1, c2|
      cn1 = c1.content.send(options[:sort_by].to_sym)
      cn2 = c2.content.send(options[:sort_by].to_sym)

      cn1 = cn1.downcase if cn1.is_a?(String)
      cn2 = cn2.downcase if cn2.is_a?(String)

      cn1 <=> cn2
    end

    # optionally correct order
    sorted_children.reverse! if options[:order] == 'desc'

    without_search_reindex do
      self.reorder_children(sorted_children.map {|child| child.id })
    end
  end

  # Returns this node's content's class without hitting the database or instantiating the content object.
  # Use this instead of +@node.content.class+.
  def content_class
    @content_class ||= case content_type
      # add classes that use STI
      when 'Event':   content.class
      when 'Link':    content.class
      when 'Section': content.class
      else content_type.constantize
    end
  end

  def self.root
    Node.roots.first || raise(ActiveRecord::RecordNotFound, "No root node found!")
  end

  def self.find_related_nodes(node, options = {})
    Node.find_accessible(:all,
        :conditions => [ 'node_categories.category_id in (?) AND nodes.id <> ?', node.category_ids, node.id ],
        :include    => :node_categories,
        :parent     => options[:top_node],
        :for        => options[:for],
        :limit      => options[:limit] || 5
      )
  end

  def self.bulk_update(user, nodes, attributes)
    Node.transaction do
      nodes.each do |node|
        content = node.content

        if content.respond_to?(:update_attributes_for_user!)
          content.update_attributes_for_user!(user, attributes)
        else
          content.update_attributes!(attributes)
        end
      end
    end
    
    true
  rescue
    false
  end

  attr_accessor :keep_existing_categories
  alias_method :original_category_ids=, :category_ids=
  def category_ids=(new_category_ids)
    new_category_ids = new_category_ids.reject(&:blank?).map(&:to_i)

    return if new_category_ids.empty?  
    
    if keep_existing_categories
      self.original_category_ids = (new_category_ids + category_ids).uniq
    else
      self.original_category_ids = new_category_ids.uniq
    end
  end
  
  def last_set_category
    @last_set_category ||= self.node_categories.first(:order => 'created_at DESC').try(:category)
  end
  
  # Override ancestry setter to correctly check wether the sortable scope is changed. This will prevent subtree repositioning issues.
  def ancestry=(value)
    sortable_scope_changes << :ancestry unless sortable_scope_changes.include?(:ancestry) || new_record? || (send(:ancestry).present? && value.to_s.split("/").last == send(:ancestry).to_s.split("/").last) || !self.class.sortable_lists.any? { |list_name, configuration| configuration[:scope].include?(:ancestry) }
    self.ancestry_without_sortable = value
  end
  

protected

  # Swap can only swap with siblings, so no validity check is needed.
  def swap(target, transact = true)
    move_to_without_validity_check_and_alias_update(target, :swap, transact)
  end

  # Cleans a URL by stripping any whitespace characters, transliterating any
  # special characters, replacing illegal characters by hyphens and converting
  # the entire URL to downcase.
  def clean_for_url(url)
    result = Iconv.iconv('ascii//ignore//translit', 'utf-8', help.strip_tags(url.strip)).join.downcase.gsub(/[^\/a-z0-9]/,'-').gsub(/-{2,}/,'-').gsub(/\/$/, "")
    
    # remove any leading and trailing hyphens, also when directly after a slash
    result = $1 while result =~ /\A-(.*)/
    result = $1 while result =~ /(.*)-\z/
    result.gsub!(/\/-/, '/')
    return result
  end

  # Prevents a +Node+ from being directly instantiated.
  def should_not_be_directly_instantiated
    errors.add_to_base(:not_directly) unless content && !content.new_record?
  end

  # Prevents the root +Node+ from being destroyed.
  def prevent_root_destruction
    raise ActiveRecord::ActiveRecordError, I18n.t('activerecord.errors.models.node.attributes.base.cant_remove_root') if self.root?
  end

  # Determines the "content date" of the content
  # This is used to determine whether the content date is "past", "current" or "future"
  def determine_content_date(today)
    # For NewsItem and NewsletterEdition instance, we only look at the publication date
    if content_class == NewsItem || content_class == NewsletterEdition
      content_date = self.publication_start_date.to_date
    # For CalendarItem and Meeting instances, we look at both the start and end times
    else
      start_date = content.start_time.to_date
      end_date   = content.end_time.to_date

      # The event has already ended
      if end_date < today
        content_date = end_date
      # The event has yet to start
      elsif start_date > today
        content_date = start_date
      # Either the event ends or starts today, or is still taking place today
      else
        content_date = today
      end
    end

    content_date
  end
  
  def save_category_attributes
    if self.category_attributes.present?
      self.category_attributes.each do |id, attrs|
        self.categories.find(id).update_attributes(attrs)
      end
    end
  end
end

# == Schema Information
#
# Table name: nodes
#
#  id                          :integer         not null, primary key
#  content_type                :string(255)     not null
#  content_id                  :integer         not null
#  created_at                  :datetime
#  updated_at                  :datetime
#  hidden                      :boolean         default(FALSE)
#  url_alias                   :string(255)
#  status                      :string(255)     default("approved")
#  edited_by                   :integer
#  show_in_menu                :boolean         default(FALSE), not null
#  commentable                 :boolean         default(FALSE)
#  external_id                 :string(255)
#  has_changed_feed            :boolean         default(FALSE)
#  hide_right_column           :boolean         default(FALSE)
#  editor_comment              :text
#  hits                        :integer         default(0), not null
#  publication_start_date      :datetime
#  publication_end_date        :datetime
#  columns_mode                :boolean         default(FALSE)
#  content_box_title           :string(255)
#  content_box_icon            :string(255)
#  content_box_colour          :string(255)
#  content_box_number_of_items :integer
#  ancestry                    :string(255)
#  position                    :integer
#
