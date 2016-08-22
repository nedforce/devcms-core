# A node is a proxy for different types of content, so that all types of
# content may be managed in a uniform manner. A node cannot be instantiated
# directly, instead one will be automatically created when the associated
# content node is saved.
#
# For example, pages and news archives are two different types of content, yet
# both should be referrable as an URL and linkable in a menu. Because both types
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
# the website's taxonomy of content nodes and is implemented using
# AwesomeNestedSet.
# Content node types can have certain constraints applied to it regarding its
# accepting types (i.e. content node types of which content nodes are accepted
# as children), and whether it is insertable in content nodes of any type
# (default) or not. See +acts_as_content_node+ for more information on how to do
# this.
#
# <b>Content type register</b>
#
# The Node class also houses the content type register. If a new content type is
# to be implemented do not forget to add it to the array returned by
# +Node#content_types+.
#
# *Specification*
#
# Attributes
#
# * +content+               - The associated content node.
# * +layout+                - The layout, this maybe nil.
# * +layout_variant+        - The layout variant, this maybe nil.
# * +layout_configuration+  - Serialized hash of additional options to be used
#                             by the layout, this maybe nil.
# * +url_alias+             - An URL alias for this node.
# * +commentable+           - True if a node can be commented on, else false.
# * +content_box_title+     - The title of the content box representation of
#                             this node (see SideboxElement).
# * +content_box_icon+      - The icon of the content box representation of this
#                             node.
# * +content_box_colour+    - The colour of the content box representation of
#                             this node.
# * +content_box_number_of_items+ - The number of items of the content box
#                                   representation of this node.
#
# Preconditions
#
# * Requires the presence of +content+.
# * Requires the uniqueness of +content+.
# * Requires the uniqueness of +url_alias+ if not blank.
# * Requires a properly formatted +url_alias+ if not blank.
# * Requires +url_alias+ to not contain any reserved words if not blank.
# * Requires !is_global_frontpage? && !contains_global_frontpage? to hide.
# * Requires +external_id+ to be unique with in the scope of its parent.
#   Allows nil.
#
# Postconditions
#
# * The content node will be destroyed before this node is.
#
class Node < ActiveRecord::Base
  # A node is commentable.
  acts_as_commentable

  # Nodes are taggable with alterative titles & tags.
  acts_as_taggable_on :title_alternatives
  acts_as_ordered_taggable_on :tags

  # Prevents the root +Node+ from being destroyed.
  before_destroy :prevent_root_destruction

  # Delegate tree calls to use Ancestry. Ensure this is added *after* other
  # before/after filters.
  include NodeExtensions::TreeDelegation

  # Load paranoid delete functionality. Make sure this is loaded after
  # +Node::TreeDelegation+ and before any other extensions.
  include NodeExtensions::ParanoidDelete

  # # Load visibility & accessibility functionality.
  include NodeExtensions::VisibilityAndAccessibility

  # Load expiration functionality.
  include NodeExtensions::Expiration

  # Load layout & template functionality.
  include NodeExtensions::Layouting

  # Load Url Aliasing functionality. Should be loaded after TreeDelegation as it
  # overrides +move_to+.
  include NodeExtensions::UrlAliasing

  # Load content type configuration functionality.
  include NodeExtensions::ContentTypeConfiguration

  # Override +move_to+ to support reindexing after move.
  include NodeExtensions::MoveToWithReindexing

  if Devcms.search_configuration[:enabled_search_engines].try(:include?, 'ferret')
    extend Search::Modules::Ferret::FerretNodeExtension
    acts_as_searchable
  end

  INDEX_DATETIME_FORMAT = '%Y%m%d%H%M'

  has_many :combined_calendar_nodes, dependent: :destroy
  has_many :combined_calendars,      through: :combined_calendar_nodes

  belongs_to :content,          polymorphic: true, dependent: :destroy
  belongs_to :responsible_user, class_name: 'User'

  has_many :links,            dependent: :destroy, class_name: 'InternalLink', foreign_key: :linked_node_id
  has_many :copies,           dependent: :destroy, class_name: 'ContentCopy',  foreign_key: :copied_node_id
  has_many :role_assignments, dependent: :destroy

  has_many :abbreviations, dependent: :destroy
  has_many :synonyms,      dependent: :destroy

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  # See the preconditions overview for an explanation of these validations.
  validates :content,                presence: true
  validates :sub_content_type,       presence: true
  validates :publication_start_date, presence: true

  validates_presence_of   :deleted_at, if: lambda { |node| node.parent.try(:deleted_at) }

  validates_uniqueness_of :content_id, scope: :content_type

  validates_inclusion_of :publishable, in: [false, true], allow_nil: false

  validates_inclusion_of :commentable, in: [false, true], allow_nil: true

  validates_inclusion_of :content_box_colour, in: Devcms.content_box_colours, allow_blank: true
  validates_inclusion_of :content_box_icon,   in: Devcms.content_box_icons,   allow_blank: true, if: Proc.new { Rails.application.config.use_devcms_icons }

  validates :content_box_title, :content_box_url, length: 2..255, allow_blank: true

  validate  :ensure_publication_start_date_is_present_when_publication_end_date_is_present,
            :ensure_publication_end_date_after_publication_start_date,
            :ensure_content_box_number_of_items_should_be_greater_than_two,
            :ensure_maximum_tags

  delegate  :has_related_content?, to: :content

  before_validation :set_publication_start_date_to_current_time_if_blank

  # After update to private or hidden or publishable reindex all children
  before_update do |node|
    @private_changed     = node.private_changed?
    @hidden_changed      = node.hidden_changed?
    @publishable_changed = node.publishable_changed?
    true
  end

  after_update { |node| node.reindex_self_and_children if @private_changed || @hidden_changed || @publishable_changed; true }

  # Remove from list on paranoid delete
  before_paranoid_delete :remove_from_list
  before_paranoid_restore :add_to_list_bottom
  before_paranoid_restore :add_descendants_to_list

  # Prevents the root +Node+ from being marked as deleted.
  before_paranoid_delete :prevent_root_destruction

  # Make sure the associated meta content is removed (or marked as deleted) for the entire subtree when the current node is marked as deleted
  before_paranoid_delete :remove_associated_meta_content

  after_paranoid_delete do
    NodeSweeper.instance.after_update(self)
  end

  scope :default_order, -> { ordered_by_ancestry.order('nodes.position') }

  scope :sorted_by_position, -> { order('nodes.position') }

  scope :exclude_subtrees_of, (lambda do |nodes_to_exclude|
    Node.exclude_subtrees_conditions_for(nodes_to_exclude)
  end)

  scope :shown_in_menu, (lambda do
    menu_scope = where('nodes.show_in_menu' => true)
    if Node.content_to_hide_from_menu.present?
      menu_scope.where('nodes.sub_content_type NOT IN (?)', Node.content_to_hide_from_menu)
    else
      menu_scope
    end
  end)

  scope :with_content_type, (lambda do |content_types_to_include|
    content_types_to_include = Array(content_types_to_include)

    if content_types_to_include.present?
      where('nodes.sub_content_type IN (?)', content_types_to_include)
    else
      self
    end
  end)

  scope :exclude_content_types, (lambda do |content_types_to_exclude|
    content_types_to_exclude = Array(content_types_to_exclude)

    if content_types_to_exclude.present?
      where('nodes.sub_content_type NOT IN (?)', content_types_to_exclude)
    else
      self
    end
  end)

  scope :sections, -> { where(sub_content_type: %w( Section Site )) }

  scope :include_content, -> { includes(:content) }

  scope :path_children_by_depth, ->(node){ order('nodes.ancestry_depth desc, nodes.position asc').where(ancestry: node.path_child_ancestries) }

  # The Helper class includes the SanitizeHelper for proxy access.
  class Helper
    include Singleton
    include ActionView::Helpers::SanitizeHelper
    extend  ActionView::Helpers::SanitizeHelper::ClassMethods
  end

  def self.content_to_hide_from_menu
    @content_to_hide_from_menu ||= self.content_types_configuration.select do |content_type, configuration|
      !configuration[:show_in_menu]
    end.map(&:first)
  end

  def related_content(limit = nil)
    find_related_tags[0..(limit || self.content_box_number_of_items || 10) - 1]
  end

  def content_copy?
    self.content_type == ContentCopy.name
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
      :creatableChildContentTypes => self.content_type_configuration[:allowed_child_content_types].inject([]) do |array, child_content_type|
        child_content_type_configuration = Node.content_type_configuration(child_content_type) || {}
        klass = child_content_type.constantize

        if child_content_type_configuration[:enabled] && child_content_type_configuration[:allowed_roles_for_create].include?(role_name)
          array << {
            :text           => klass.human_name,
            :modelName      => child_content_type,
            :controllerName => "/admin/#{klass.controller_name}"
          } unless self.content_class == Site && klass == Site && !self.root? # Prevent nesting of sites deeper than 1
        end

        array
      end.sort_by { |hash| hash[:text] },
      :allowedChildContentTypes        => self.content_type_configuration[:allowed_child_content_types],
      :ownContentType                  => self.content_class.name,
      :allowEdit                       => !self.content_copy? && self.content_type_configuration[:allowed_roles_for_update].include?(role_name),
      :controllerName                  => "/admin/#{self.content.controller_name}",
      :parentNodeId                    => self.parent_id,
      :parentURLAlias                  => self.parent_url_alias,
      :customURLSuffix                 => self.custom_url_suffix.present? ? self.custom_url_suffix : nil,
      :customURLAlias                  => self.custom_url_alias.present? ? self.custom_url_alias : nil,
      :URLAlias                        => self.url_alias.present? ? self.url_alias : nil,
      :host                            => "http://#{self.containing_site.content.domain}/",
      :contentNodeId                   => self.content_id,
      :siteNodeId                      => self.containing_site.id,
      :topLevelPrivateAncestorId       => self.top_level_private_ancestor.try(:id),
      :userRole                        => role ? role_name : nil,
      :undeletable                     => self.root? || !content_type_configuration[:allowed_roles_for_destroy].include?(role_name) || (!user_is_admin && self.content_class == Image && self.content.is_for_header?),
      :allowGlobalFrontpageSetting     => user_is_admin,
      :isContentCopy                   => self.content_copy?,
      :isFrontpage                     => self.is_frontpage?,
      :isGlobalFrontpage               => self.is_global_frontpage?,
      :isRepeatingCalendarItem         => self.content_class <= CalendarItem && self.content.has_repetitions?,
      :containsGlobalFrontpage         => self.contains_global_frontpage?,
      :allowTogglePrivate              => self.content_class <= Section && user_is_admin,
      :allowToggleHidden               => user_is_final_editor || user_is_admin,
      :allowShowInMenu                 => !self.content_copy? && !Node.content_to_hide_from_menu.include?(self.sub_content_type),
      :isHidden                        => self.hidden?,
      :isPrivate                       => self.private?,
      :showInMenu                      => self.show_in_menu,
      :hasChangedFeed                  => self.has_changed_feed,
      :allowToggleChangedFeed          => content_type_configuration[:has_own_feed] || [ Feed, Section, Site ].include?(self.content_class),
      :hasPrivateAncestor              => self.has_private_ancestor?,
      :hasHiddenAncestor               => self.has_hidden_ancestor?,
      :allowUrlAliasSetting            => user_is_final_editor || user_is_admin,
      :allowContentCopyCreation        => !self.root? && !self.content_copy? && content_type_configuration[:copyable],
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

    hash.merge(Devcms.tree_node_for(self, user, options))
  end

  # Checks whether the node is expandable (in the admin view) for the given user.
  # A node is expandable if the user has a role on the node itself or one of its
  # descendants.
  def is_expandable_for_user?(user)
    user.role_on(self) || user.role_assignments.joins(:node).where(descendant_conditions).first
  end

  # Returns the text that should be displayed in the node tree
  def tree_text
    tree_text = ''

    latest_version = content.versions.current

    if latest_version.present?
      tree_text += ' <i>('

      if latest_version.drafted?
        tree_text += I18n.t('nodes.draft')
      elsif latest_version.rejected?
        tree_text += I18n.t('nodes.rejected')
      else
        tree_text += I18n.t('nodes.unapproved')
      end

      tree_text += ')</i>'
    end
    "#{content.current_version.tree_text(self)}#{tree_text.html_safe}"
  end

  # Returns the site that directly contains this node as a descendant
  def containing_site
    return @containing_site if defined?(@containing_site)

    @containing_site = if depth.zero?
      Node.root
    else
      node = Node.find(path_ids[1]) rescue nil
      node && node.sub_content_type == 'Site' ? node : Node.root
    end
  end

  # Returns true if this node is published, false otherwise.
  def published?
    now = Time.now

    publication_start_date <= now && (publication_end_date.blank? || publication_end_date >= now)
  end

  def visible?
    !hidden? && !private? && publishable?
  end

  # Increments the hits counter without updating the updated_at value.
  # This implementation does not affect the +updated_at+ field.
  def increment_hits!
    Node.without_search_reindex do # No update of the search index is necessary.
      Node.increment_counter :hits, id
    end
  end

  # See :increment_hits! Same construct, but now for removing a percentage of
  # the hits.
  def self.reduce_hit_count(factor = 0.9)
    Node.without_search_reindex do
      connection.update("UPDATE nodes SET hits = hits * #{1 - factor}")
    end
  end

  def last_changes(on, options = {})
    scope = nil

    if on == :all
      # Exclude other sites
      nodes_to_exclude = descendants.with_content_type('Site')

      # Exclude private sections
      nodes_to_exclude += descendants.sections.is_private
      scope = self_and_descendants.exclude_subtrees_of(nodes_to_exclude).with_content_type(%w( Page Section NewsItem ))
    elsif on == :self
      scope = self_and_descendants(to_depth: 0).is_public.exclude_content_types('Site')
    end

    if scope
      scope = scope.accessible.include_content.order(updated_at: :desc)
      scope = scope.limit(options[:limit]) if options[:limit]
      scope
    end
  end

  def reindex_self_and_children
    self_and_descendants.each(&:update_search_index) if respond_to?(:update_index)
  end

  def disable_search_reindex_until_saved
    disable_reindex_until_saved if respond_to?(:disable_reindex_until_saved)
  end

  def add_to_search_index
    add_to_index if respond_to?(:add_to_index)
  end

  def update_search_index
    update_index if respond_to?(:update_index)
    true
  end

  def without_search_reindex(&block)
    if respond_to?(:without_reindex)
      without_reindex(&block)
    else
      yield
    end
  end

  def self.without_search_reindex(&block)
    if respond_to?(:without_reindex)
      Node.without_reindex(&block)
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
  # [:sort_by]   (Symbol) Property to sort by, e.g. :content_title or
  #                       :created_at. (Defaults to :content_title.)
  # [:order]     (String) Either 'desc' for descending order or 'asc' for
  #                       ascending order. (Defaults to 'asc'.)
  def sort_children(options = {})
    options = { sort_by: :content_title, order: 'asc' }.merge(options)

    # sort in memory
    sorted_children = children.sort do |c1, c2|
      cn1 = c1.content.send(options[:sort_by].to_sym)
      cn2 = c2.content.send(options[:sort_by].to_sym)

      cn1 = cn1.downcase if cn1.is_a?(String)
      cn2 = cn2.downcase if cn2.is_a?(String)

      cn1 <=> cn2
    end

    # optionally correct order
    sorted_children.reverse! if options[:order] == 'desc'

    without_search_reindex do
      reorder_children(sorted_children.map(&:id))
    end
  end

  # Returns this node's content's class without hitting the database or
  # instantiating the content object.
  # Use this instead of +@node.content.class+.
  def content_class
    return @content_class if defined?(@content_class)

    if sub_content_type.nil? || sub_content_type == 'ContentCopy'
      content_class = sub_content_type.nil? ? content.class : content.copied_content_class
      @content_class = content_class unless content_class == ContentCopy
      content_class
    else
      @content_class = sub_content_type.constantize
    end
  end

  # This method is used to cache the titles of content nodes, so we don't have
  # to query separately for them.
  def content_title
    if %w(ExternalLink InternalLink MailLink Feed ContentCopy).include?(sub_content_type)
      content.try(:content_title)
    else
      title.blank? ? content.try(:content_title) : title
    end
  end

  def menu_title
    short_title.blank? ? content_title : short_title
  end

  def self.root
    Node.roots.first || raise(ActiveRecord::RecordNotFound, 'No root node found!')
  end

  def self.find_related_nodes(node, options = {})
    (options[:top_node] ? options[:top_node].children : Node.scoped).accessible.is_public.includes(:node_categories).limit(options[:limit] || 5).where(['node_categories.category_id in (?) AND nodes.id <> ?', node.category_ids, node.id])
  end

  # 25/11/2013: Bulk updates were used for node categories, which have been
  # removed later. Might need it in the future, therefore it's still available.
  def self.bulk_update(nodes, attributes, user = nil)
    Node.transaction do
      nodes.each do |node|
        content = node.content

        if content.class.requires_editor_approval? && user.present?
          content.update_attributes!(attributes.merge(user: user))
        else
          content.update_attributes!(attributes)
        end
      end
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  # Determines the "content date" of the content. This is used to determine
  # whether the content date is "past", "current" or "future".
  def determine_content_date(today)
    # For NewsItem and NewsletterEdition instance, we only look at the
    # publication date.
    if content_class == NewsItem || content_class == NewsletterEdition
      content_date = publication_start_date.to_date
    # For CalendarItem and Meeting instances, we look at both the start and
    # end times.
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

  def title_alternatives
    super.map(&:name).join(',')
  end

  def self.available_tags
    ActsAsTaggableOn::Tag.select('DISTINCT(name)').joins(:taggings).where(taggings: { context: :tags }).map(&:name)
  end

  def footer_links
    @footer_links ||= (own_or_inherited_layout_configuration['footer_links'] || parent_footer_links)
  end

  def parent_footer_links
    if parent
      parent.own_or_inherited_layout_configuration['footer_links'] ? parent.own_or_inherited_layout_configuration['footer_links'] : parent.parent_footer_links
    end
  end

  protected

  # Swap can only swap with siblings, so no validity check is needed.
  def swap(target, transact = true)
    move_to_without_validity_check_and_alias_update(target, :swap, transact)
  end

  # Prevents the root +Node+ from being destroyed.
  def prevent_root_destruction
    raise ActiveRecord::ActiveRecordError, I18n.t('activerecord.errors.models.node.attributes.base.cant_remove_root') if root? && deleted_at.blank?
  end

  def remove_associated_meta_content
    nodes_to_be_paranoid_deleted_ids = subtree_ids

    transaction do
      # Destroy all content copies that are associated with any of the nodes in
      # the subtree and are not a descendant.
      ContentCopy.includes(:node).references(:nodes).where('copied_node_id IN (:nodes_to_be_paranoid_deleted_ids) AND NOT nodes.id IN (:nodes_to_be_paranoid_deleted_ids)', nodes_to_be_paranoid_deleted_ids: nodes_to_be_paranoid_deleted_ids).find_each(&:destroy)

      # Destroy all internal links that are associated with any of the nodes in
      # the subtree and are not a descendant.
      InternalLink.includes(:node).references(:nodes).where('linked_node_id IN (:nodes_to_be_paranoid_deleted_ids) AND NOT nodes.id IN (:nodes_to_be_paranoid_deleted_ids)', nodes_to_be_paranoid_deleted_ids: nodes_to_be_paranoid_deleted_ids).find_each(&:destroy)

      # Unset frontpage for Sections.
      Section.where(frontpage_node_id: nodes_to_be_paranoid_deleted_ids).update_all(frontpage_node_id: nil)

      # Delete any role assignments, synonyms or abbreviations that are
      # associated with any of the nodes in the subtree.
      [RoleAssignment, Synonym, Abbreviation, CombinedCalendarNode].each do |klass|
        klass.where(node_id: nodes_to_be_paranoid_deleted_ids).delete_all
      end

      # Do the same for all comments.
      Comment.where(commentable_id: nodes_to_be_paranoid_deleted_ids).delete_all

      # Delete content representations where appropriate.
      ContentRepresentation.where('parent_id IN (:nodes_to_be_paranoid_deleted_ids) OR content_id IN (:nodes_to_be_paranoid_deleted_ids)', nodes_to_be_paranoid_deleted_ids: nodes_to_be_paranoid_deleted_ids).delete_all
    end
  end

  # Sets the publication_end_date to current time if none is specified.
  def set_publication_start_date_to_current_time_if_blank
    self.publication_start_date = Time.now unless publication_start_date
  end

  private

  # Validation methods

  def ensure_publication_start_date_is_present_when_publication_end_date_is_present
    if publication_end_date
      errors.add(:base, I18n.t('acts_as_content_node.publication_start_date_should_be_present')) unless publication_start_date
    end
  end

  def ensure_publication_end_date_after_publication_start_date
    if publication_start_date && publication_end_date && publication_start_date >= publication_end_date
      errors.add(:base, I18n.t('acts_as_content_node.publication_end_date_should_be_after_publication_start_date'))
    end
  end

  def ensure_content_box_number_of_items_should_be_greater_than_two
    if content_box_number_of_items && content_box_number_of_items.to_i <= 2
      errors.add(:base, I18n.t('acts_as_content_node.content_box_number_of_items_should_be_greater_than_two'))
    end
  end

  def ensure_maximum_tags
    errors.add(:tags, I18n.t('node.number_of_tags_should_be_lt_3')) if tags.count > 3
  end

  ActiveSupport.run_load_hooks(:node, self)
end
