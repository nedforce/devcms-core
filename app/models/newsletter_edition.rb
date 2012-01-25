# This model is used to represent a newsletter edition item. A newsletter edition is contained within
# a newsletter archive, which in turn is represented by the +NewsletterArchive+ model. A newsletter edition
# can contain multiple +NewsItem+ objects. It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the newsletter edition.
# * +body+ - The description of the newsletter edition.
# * +newsletter_archive+ - The newsletter archive that this newsletter edition belongs to.
# * +published+ - Setting whether this newsletter edition is published.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +body+.
# * Requires the presence of +newsletter_archive+.
# 
# Child/parent type constraints
# 
#  * A NewsLetterEdition only accepts +news_item+ child nodes.
#  * A NewsLetterEdition can only be inserted into NewsLetterArchive nodes.
#
class NewsletterEdition < ActiveRecord::Base
  # Adds content node functionality to newsletter editions.
  acts_as_content_node({
    :show_in_menu => false,
    :copyable => false
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # A +NewsletterEdition+ belongs to a +NewsletterArchive+.
  has_parent :newsletter_archive

  # A +NewsletterEdition+ has many +NewsletterEditionItem+ objects and many items through +NewsletterEditionItem+.
  has_many :newsletter_edition_items,  :dependent => :destroy
  has_many :newsletter_edition_queues, :dependent => :destroy

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title, :body, :newsletter_archive
  validates_length_of   :title, :in => 2..255, :allow_blank => true

  after_paranoid_delete :remove_associated_content

  # Retrieves the items belonging to this newsletter edition in correct order.
  def items
    self.newsletter_edition_items.all(:order => "position ASC").map { |ed_item| ed_item.item}
  end

  # Returns the number of items belonging to this newsletter edition.
  def items_count
    self.newsletter_edition_items.count
  end
  
  # Adds items to a +NewsletterEdition+, which must be a +Page+ or a +NewsItem+. Old associations are removed first.
  #
  # Parameters: An array containing node IDs. The order of the items in the array determines the positions of the items 
  # in the newsletter edition.
  def associate_items(items)
    # Use delete_all instead of destroy_all (quicker).
    NewsletterEditionItem.delete_all "newsletter_edition_id = #{self.id}"
    
    # Add the new items.
    if items
      items.each_index do |index| 
        self.newsletter_edition_items.create(:item => Node.find(items.at(index)).content, :position => index)   
      end
    end
  end

  # Alternative text for tree nodes.
  def tree_text(node)
    "#{node.publication_start_date.day}/#{node.publication_start_date.month} #{self.title}"
  end

  # Returns the body as the token for indexing.
  def content_tokens
    body
  end

  # Returns a URL alias for a given +node+.
  def path_for_url_alias(node)
    "#{node.publication_start_date.year}/#{node.publication_start_date.month}/#{node.publication_start_date.day}/#{self.title}"
  end

protected

  def remove_associated_content
    self.newsletter_edition_items.destroy_all
    self.newsletter_edition_queues.destroy_all
  end
  
end
