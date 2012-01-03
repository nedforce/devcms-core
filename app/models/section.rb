# This model is used to represent a website section. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the section.
# * +description+ - The description of the section.
# * +frontpage_node+ - The node that is the frontpage of this Section. Can be blank.
#
# Preconditions
#
# * Requires the presence of +title+.
#
# * Requires +frontpage_node+ to be nil if the +Section+ has a frontpage.
# * Requires +frontpage_node+ of the +Section+ to be a descendant of the Section.
# * Requires +frontpage_node+ to not be a +Section+ with a frontpage_node.
#
# Child/parent type constraints
#
#  * A Section accepts nodes of any type.
#  * A Section can be inserted into nodes of any accepting type.
#
class Section < ActiveRecord::Base

  # Adds content node functionality to sections.
  acts_as_content_node({
    :allowed_child_content_types => %w(
      AlphabeticIndex Attachment AttachmentTheme Calendar Carrousel CombinedCalendar ContactBox ContactForm Feed Forum
      HtmlPage Image LinksBox InternalLink ExternalLink NewsArchive NewsletterArchive NewsViewer
      Page Poll SearchPage Section SocialMediaLinksBox TopHitsPage WeblogArchive
    ),
    :allowed_roles_for_create  => %w( admin final_editor ),
    :allowed_roles_for_destroy => %w( admin final_editor ),
    :available_content_representations => ['content_box'],
    :has_own_content_box => true,
    :expiration_container=> true
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # The node that is the frontpage of this Section. Can be blank.
  belongs_to :frontpage_node, :class_name => "Node"

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :title
  validates_length_of       :title, :in => 2..255
  validates_numericality_of :frontpage_node_id, :allow_nil => true,                                            :on => :update
  validates_presence_of     :frontpage_node, :unless => Proc.new { |section| section.frontpage_node_id.nil? }, :on => :update

  # Ensures +frontpage_node+ should be nil if the +Section+ object has a frontpage.
  validate_on_create :frontpage_node_is_nil

  # Sets +frontpage_node+ to nil if the +Section+ is the frontpage node.
  before_validation_on_update :set_frontpage_node_to_nil_if_frontpage_node_is_own_node

  # Ensures the +frontpage_node+ should be a descendant.
  validate_on_update :frontpage_node_is_a_descendant
  # Ensures the +frontpage_node+ is no +Section+ with a frontpage node.
  validate_on_update :frontpage_node_is_no_section_with_frontpage_node

  # Returns the last update date
  def last_updated_at
    self.node.self_and_descendants.accessible.exclude_content_types(%w( Image Attachment Site )).maximum(:updated_at)
  end

  # Returns the maximum number of sidebox (content box) columns that are allowed for this content type.
  def self.max_number_of_columns
    4
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  # Returns true if the section has a frontpage.
  def has_frontpage?
    !self.frontpage_node.nil?
  end

  # Returns the frontpage if one is present.
  def frontpage
    has_frontpage? ? self.frontpage_node.content : nil
  end

  # Sets the frontpage to the given +node+.
  def set_frontpage!(node)
    self.update_attributes(:frontpage_node => node)
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end

protected

  # Ensures +frontpage_node+ should be nil if the +Section+ object has a frontpage.
  def frontpage_node_is_nil
    errors.add_to_base(:frontpage_node_should_be_nil) if self.has_frontpage?
  end

  # Sets +frontpage_node+ to nil if the +Section+ is the frontpage node.
  def set_frontpage_node_to_nil_if_frontpage_node_is_own_node
    if has_frontpage?
      self.frontpage_node = nil if self.frontpage_node == self.node
    end
  end

  # Ensures the +frontpage_node+ should be a descendant.
  def frontpage_node_is_a_descendant
    if has_frontpage?
      errors.add_to_base(:frontpage_node_should_be_descendant) unless self.frontpage_node.is_descendant_of?(self.node)
    end
  end

  # Ensures the +frontpage_node+ is no +Section+ with a frontpage node.
  def frontpage_node_is_no_section_with_frontpage_node
    if has_frontpage?
      errors.add_to_base(:frontpage_node_cannot_be_a_section_with_a_frontpage) if self.frontpage_node.content.is_a?(Section) && !self.frontpage_node.content.frontpage_node.nil?
    end
  end
end
