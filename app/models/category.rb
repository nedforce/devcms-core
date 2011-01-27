# Content can belong to a category, which can be used as metadata. In contrast
# to tags, categories may have a parent category.
#
# Attributes
#
# * +name+ - The name of the category.
# * +parent+ - The parent category (if any).
# * +nodes+ - The nodes that are member of this category.
# * +synonyms+ - The synonyms of this category (as a comma-separated string).
#
# Preconditions
#
# * Requires the presence of +name+.
# * Requires root categories to have a unique name.
#
class Category < ActiveRecord::Base

  # A Category optionally belongs to an other Category. And thus a Category
  # may also have child Category objects.
  belongs_to :parent, :class_name => 'Category'
  has_many :children, :class_name => 'Category', :foreign_key => 'parent_id'

  has_many :node_categories, :dependent => :destroy
  has_many :nodes,           :through => :node_categories

  has_many :user_categories, :dependent => :destroy

  # Prevents destruction if there are still nodes referencing this category.
  before_destroy :check_for_children

  # Convert the synonyms into a consistent comma-separated string.
  before_save :process_synonyms

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :name
  validate :root_category_unique

  # Root categories are categories without a parent category.
  named_scope :root_categories, :conditions => 'parent_id is NULL'

  # Regular categories are categories with a parent category.
  named_scope :categories, :conditions => 'parent_id is NOT NULL'

  # Default sort by name.
  default_scope :order => 'name ASC'

  # Returns true when this category has no parent category.
  def is_root_category?
    parent.nil?
  end

  # Returns a text representation of this category. This will just be the category name for root categories;
  # child categories on the other hand will be prepended with the name of the parent category.
  def to_label
    parent.nil? ? name : "#{parent.name} | #{name}"
  end

  private

  # Prevents destruction if there are still nodes referencing this category.
  def check_for_children
    if nodes.any?
      errors.add_to_base(:elements_still_present)
      false
    end
  end

  # Ensures the names of the root categories remain unique.
  def root_category_unique
    errors.add(:name, :must_be_unique) if Category.root_categories.all.map {|c| c.name unless c == self }.include?(self.name)
  end

  # Ensures the list of comma-separated synonyms is in a standard format.
  def process_synonyms
    self.synonyms = self.synonyms.split(',').reject(&:blank?).map(&:strip).join(', ') if self.synonyms
  end
end
