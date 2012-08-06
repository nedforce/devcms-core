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

  # Default content types to exclude from the top hits.
  DEFAULT_CONTENT_TYPES_TO_EXCLUDE = %w(
    Calendar CombinedCalendar NewsArchive NewsletterArchive Section Forum ForumTopic WeblogArchive Image HeaderImage ContactBox Attachment TopHitsPage
  )
  
  # Default number of top hits to show
  DEFAULT_AMOUNT_TO_SHOW = 10

  # Adds content node functionality to top hits pages.
  acts_as_content_node({
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => %w( content_box )
  })

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255, :allow_blank => true

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end
  
  def self.content_types_to_exclude
    DEFAULT_CONTENT_TYPES_TO_EXCLUDE
  end

  # Finds the content nodes within the current site that have been shown the most and are publicly accessible.
  def find_top_hits(options = {})
    return @top_hits if @top_hits
    
    include_content = options.has_key?(:include_content) ? options.delete(:include_content) : false
    nodes_to_exclude = options.delete(:nodes_to_exclude) || []
    content_types_to_exclude = options.delete(:content_types_to_exclude) || TopHitsPage.content_types_to_exclude
    
    # This method can be called when the record hasn't been saved yet, i.e., for the admin preview
    containing_site = (self.node.nil? || self.node.new_record? ? self.parent : self.node).containing_site
    
    # Exclude other sites
    nodes_to_exclude += containing_site.descendants.with_content_type('Site')
    
    # Exclude private sections
    nodes_to_exclude += containing_site.descendants.sections.private

    limit = options.delete(:limit) || DEFAULT_AMOUNT_TO_SHOW
    order = options.delete(:order) || "hits desc"
        
    top_hits_scope = containing_site.descendants.accessible.exclude_subtrees_of(nodes_to_exclude.uniq).exclude_content_types(content_types_to_exclude)
    top_hits_scope = top_hits_scope.limit(limit).reorder(order)
    
    @top_hits = if include_content
      top_hits_scope.include_content.all(options)
    else
      top_hits_scope.all(options)
    end
  end
  
end
