# This model is used to represent the mapping of a content node (for
# instance, a +Link+ instance), identified by +content+, into a column ('content box') of
# the view of an other content node (for instance, a +Section+ instance),
# identified by +parent+.
#
# <b>Ordering</b>
#
# The ordering is determined by the +position+ attribute.
#
# *Specification*
#
# Attributes
#
# * +parent+ - The content node whose side box contains the content box element.
# * +content+ - The content node contained within the content box element.
# * +target+ - The target of the content box, defined by the layout.
# * +position+ - Determines the position of the contentbox in the target
#
# Preconditions
#
# * Requires the presence of +parent+.
# * Requires the presence of +content+.
#
# * Requires each (+parent+, +content+) pair to be unique.
#
# * Requires +content+ to be allowed as side box content (as indicated by +available_content_representations?+)
# * Requires +position+, if supplied, to be greater than 0.
#
class ContentRepresentation < ActiveRecord::Base
  # Writer to set the partial name explicitly.
  attr_writer :content_partial
  # Accessor to set the partial title explicitly.
  attr_accessor :title

  # Provides list functionality to all +ContentRepresentation+ instances
  sortable :scope => :parent_id

  # The node whose side box contains the content box element.
  belongs_to :parent, :class_name => 'Node'

  # The node contained within the content box element.
  belongs_to :content, :class_name => 'Node'

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :parent, :target
  validates_presence_of     :content,                          :unless => :custom_type
  validates_uniqueness_of   :content_id, :scope => :parent_id,    :unless => :custom_type
  validates_numericality_of :parent_id
  validates_numericality_of :content_id,                          :unless => :custom_type
  
  validate :content_should_not_be_hidden,                         :unless => :custom_type
  validate :content_should_not_be_private,                        :unless => :custom_type
  
  validate :content_should_be_allowed_as_content_representation,  :unless => :custom_type
  validate :content_should_be_in_same_site,                       :unless => :custom_type
  validate :custom_type_should_exist_for_parent,                  :if => :custom_type

  before_validation :nillify_custom_type, :if => lambda { |cr| cr.custom_type.blank? }

  # Returns the name of the contentbox content partial based on node and layout
  # Can be overwitten for special cases.
  def content_partial
    @content_partial ||= self.parent.own_or_inherited_layout_variant[self.target]['representation'] + '_content'
  end
  
protected

  def content_should_not_be_hidden
    errors.add(:content, :should_not_be_hidden) if self.content && self.content.hidden?
  end
  
  def content_should_not_be_private
    if self.content && self.content.private?
      errors.add(:content, :should_not_be_private) if self.content.top_level_private_ancestor != self.parent.top_level_private_ancestor
    end
  end

  # Checkes whether +content+ is in the same site as the content box itself
  def content_should_be_in_same_site
    errors.add(:content, :should_be_in_same_site) if self.content && self.parent && !self.parent.containing_site.self_and_descendants.exists?(:id => self.content_id)
  end

  # Checks whether +content+ is allowed as content box content (as indicated by +available_content_representations?+)
  def content_should_be_allowed_as_content_representation
    errors.add(:content, :not_allowed_as) unless 
      self.content && 
      self.parent &&
      self.parent.own_or_inherited_layout_variant[self.target].present? &&
      self.content.content_type_configuration[:available_content_representations].include?(self.parent.own_or_inherited_layout_variant[self.target]['representation'])
  end
  
  def custom_type_should_exist_for_parent
    errors.add(:base, :non_existant_custom_type) unless self.parent && self.parent.own_or_inherited_layout.custom_representations.present? && self.parent.own_or_inherited_layout.custom_representations.keys.include?(self.custom_type)
  end
    
  def nillify_custom_type
    self.custom_type = nil
  end
end
