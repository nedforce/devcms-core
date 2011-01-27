# This model is used to represent a carrousel.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the carrousel.
# * +display_time_in_minutes+ - The display time in minutes of a carrousel item.
# * +current_carrousel_item_id+ - The item that is currently being shown
# * +last_cycled+ - The last time the item was cycled
#
# Preconditions
#
# * Requires the presence of +title+.
# 
# Child/parent type constraints
# 
#  * A Carrousel only accepts +CarrouselItem+ child nodes.
#
class Carrousel < ActiveRecord::Base
  ALLOWED_TIME_UNITS = [ 'minutes', 'hours', 'days', 'months' ]
  
  # Adds content node functionality to news archives.
  acts_as_content_node({
    :show_in_menu => false,
    :copyable => false,
    :allowed_roles_for_update  => %w( admin ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box']
  })
  
  belongs_to :current_carrousel_item, :class_name => 'CarrouselItem', :dependent => :destroy
  
  # A +Carrousel+ has many +CarrouselItem+ objects and many items through +CarrouselItem+.
  has_many :carrousel_items, :dependent => :destroy, :autosave => true
  
  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :title
  validates_length_of       :title, :in => 2..255,    :allow_blank => true
  validates_numericality_of :display_time_in_minutes, :allow_blank => true, :integer_only => true, :greater_than_or_equal_to => 0

  # Finds the current carrousel item and cycles it is necessary.
  def find_current_carrousel_item
    fetch_or_cycle_current_carrousel_item
  end

  # Retrieves the items belonging to this carrousel in correct order.
  def items
    carrousel_items.all.collect(&:item)
  end
  
  # Number of items in this carrousel.
  def items_count
    carrousel_items.count
  end

  # Retrieves the approved items.
  def approved_items
    items.map { |item| item.node.approved_content }
  end

  # Adds items to a +Carrousel+, which must be a +Page+, an +Image+ or a +NewsItem+. Old associations are removed first.
  # Parameters: An array containing node IDs. The order of the items in the array determines the positions of the items 
  # in the carrousel
  def associate_items(items, excerpts = {})
    # Use delete_all instead of destroy_all (quicker)
    carrousel_items.delete_all

    # Add the items
    if items
      items.each_index do |index| 
        carrousel_items.build(:item => Node.find(items.at(index)).content, :position => index, :excerpt => (excerpts.empty? ? nil : excerpts[items.at(index)]))   
      end
    end
    true
  end
  
  # Set and returns an item to be shown.
  def current_item
    @current_item ||= self.find_current_carrousel_item
    return @current_item
  end
  
  # Custom title for the content box
  def custom_content_box_title
    (current_item.try(:item) || self).title
  end
  
  # Determine whether to show the content box header
  def show_content_box_header
    current_item.present? ? !current_item.item.is_a?(Image) : true
  end
  
  # Alternative text for tree nodes.
  def tree_text(node)
    self.title
  end

  # Don't index carrousels
  def self.indexable?
    false
  end
  
  # Get display time in minutes
  def display_time_in_minutes
    read_attribute(:display_time_in_minutes) || 0
  end  
  
  # Set display time
  def display_time=(time)
    return unless time.is_a?(Array) and time.size == 2
    value = time[0].to_i; unit = time[1]
    self.display_time_in_minutes = ALLOWED_TIME_UNITS.include?(unit) ? value.send(unit)/60 : 0
  end
  
  # Get human display time
  def display_time
    case
    when display_time_in_minutes < 60
      [display_time_in_minutes,              'minutes']
    when display_time_in_minutes < (60*24)
      [display_time_in_minutes/60,           'hours']
    when display_time_in_minutes < (30*(60*24))
      [display_time_in_minutes/(60*24),      'days']
    else 
      [display_time_in_minutes/(30*(60*24)), 'months']
    end    
  end
  
private

  # Cycle the current carrousel item  if it is time to do so and fetch it
  def fetch_or_cycle_current_carrousel_item
    unless self.carrousel_items.empty?
      if self.current_carrousel_item.nil?
        Node.without_search_reindex do # No update of the search index is necessary.
          connection.update("UPDATE carrousels SET last_cycled = '#{Time.now.to_formatted_s(:db)}', current_carrousel_item_id = #{self.carrousel_items.first.id} WHERE id = #{self.id}")
        end
        self.current_carrousel_item = self.carrousel_items.first
      elsif (last_cycled + display_time_in_minutes.minutes) <= Time.now
        current_item_index = carrousel_items.index(current_carrousel_item)
        self.current_carrousel_item = carrousel_items.at( (current_item_index+1)%carrousel_items.size )
        Node.without_search_reindex do # No update of the search index is necessary.
          connection.update("UPDATE carrousels SET last_cycled = '#{Time.now.to_formatted_s(:db)}', current_carrousel_item_id = #{self.current_carrousel_item.id} WHERE id = #{self.id}")
        end
      end
      self.current_carrousel_item
    end
  end
end
