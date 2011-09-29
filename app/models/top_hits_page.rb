# A top hits page is a content node that keeps track of the content nodes that received the most hits. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the top hits page.
# * +description+ - The description of the top hits page.
#
# Preconditions
#
# * Requires the presence of +title+.
#
# Child/parent type constraints
#
#  * A +TopHitsPage+ does not accept any child nodes.
#  * A +TopHitsPage+ can be inserted into nodes of any accepting type.
#
class TopHitsPage < ActiveRecord::Base

  # Content types to exclude from the top lists.
  CONTENT_TO_EXCLUDE = %w(
    Calendar CombinedCalendar NewsArchive NewsletterArchive Section PermitArchive Forum ForumTopic WeblogArchive
    ProductCatalogue Image HeaderImage ContactBox Attachment
  )

  # Adds content node functionality to top hits pages.
  acts_as_content_node({
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box']
  })

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255, :allow_blank => true

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  # Finds up to +amount+ content nodes that have been shown the most and are publicly accessible.
  def find_top_hits(amount = nil)
    amount ||= 10

    site_node = (self.node.nil? || self.node.new_record? ? self.parent : self.node).containing_site
    subtrees_to_exclude = Site.all(:include => :node, :conditions => ["id != ?", site_node.content_id]).collect {|site| site.node }
    
    descendants_to_exclude = site_node.subtree.find_all_by_url_alias("vacatures")

    options = {
      :order => "hits DESC",
      :limit => 2 * amount,
      :conditions => [ 'content_type NOT IN (?)', CONTENT_TO_EXCLUDE ]
    }

    top_ids = site_node.subtree #.without_descendants_of(descendants_to_exclude).without_subtree_of(subtrees_to_exclude)
    top_ids = subtrees_to_exclude.reduce(top_ids) do |scope, node|
      subtree_conditions = node.subtree_conditions
      subtree_conditions.unshift("NOT (#{subtree_conditions.shift})")
      scope.scoped(:conditions => subtree_conditions)
    end
    top_ids = descendants_to_exclude.reduce(top_ids) do |scope, node|
      descendant_conditions = node.descendant_conditions
      descendant_conditions.unshift("NOT (#{descendant_conditions.shift})")
      scope.scoped(:conditions => descendant_conditions)
    end
    top_ids = top_ids.all({ :select => 'id' }.merge(options)).map { |node| node.id }
    top_ids += descendants_to_exclude.collect(&:id) if descendants_to_exclude.present?

    options.update(:limit => amount, :conditions => { :id => top_ids })

    @top_hits = Node.find_accessible(:all, options).map { |node| node.content }
  end
  
end
