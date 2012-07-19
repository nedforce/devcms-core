# This model is used to represent a carrousel.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the carrousel.
# * +display_time_in_seconds+ - The display time in seconds of a carrousel item.
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
  ALLOWED_TIME_UNITS = [ 'seconds', 'minutes', 'hours', 'days', 'months' ]
  
  ANIMATION_NONE          = 0
  ANIMATION_FADE_IN       = 1
  ANIMATION_SLIDE         = 2
  ANIMATION_DIA           = 3
  ANIMATION_SPRING        = 4
  ALLOWED_ANIMATION_TYPES = (0..4).to_a
  ANIMATION_NAMES         = { 0 => 'None', 1 => 'Fade', 2 => 'Slide', 3 => 'Dia', 4 => 'Spring' }
  
  # Adds content node functionality to news archives.
  acts_as_content_node({
    :show_in_menu                      => false,
    :show_content_box_header           => false,
    :copyable                          => false,
    :allowed_roles_for_update          => %w( admin ),
    :allowed_roles_for_create          => %w( admin ),
    :allowed_roles_for_destroy         => %w( admin ),
    :available_content_representations => ['content_box']
  })
  
  belongs_to :current_carrousel_item, :class_name => 'CarrouselItem', :dependent => :destroy
  
  # A +Carrousel+ has many +CarrouselItem+ objects and many items through +CarrouselItem+.
  has_many :carrousel_items, :autosave => true
  
  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :title
  validates_length_of       :title, :in => 2..255,    :allow_blank => true
  validates_numericality_of :display_time_in_seconds, :allow_blank => true, :integer_only => true, :greater_than_or_equal_to => 0
  validates_numericality_of :animation, :integer_only => true, :greater_than_or_equal_to => 0
  
  after_paranoid_delete :remove_associated_content
  
  def last_updated_at
    [ self.carrousel_items.maximum(:updated_at), self.updated_at ].compact.max
  end
  
  def animation
    super.to_i
  end
  
  # Finds sthe current carrousel item and cycles it is necessary.
  def find_current_carrousel_item
    fetch_or_cycle_current_carrousel_item
  end

  # Retrieves the items belonging to this carrousel in correct order.
  def items
    carrousel_items.all.map { |ci| ci.item }
  end
  
  # Number of items in this carrousel.
  def items_count
    carrousel_items.count
  end

  # Retrieves the approved items.
  def approved_items
    items.map { |item| item.content }
  end

  # Adds items to a +Carrousel+, which must be a +Page+, an +Image+ or a +NewsItem+. Old associations are removed first.
  # Parameters: An array containing node IDs. The order of the items in the array determines the positions of the items 
  # in the carrousel
  def associate_items(items, excerpts = {})
    carrousel_items.destroy_all

    # Add the items
    if items
      items.each_with_index do |item, index| 
        carrousel_items.build(:item => Node.find(item).content, :position => index, :excerpt => (excerpts.empty? ? nil : excerpts[item]))   
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

  # Alternative text for tree nodes.
  def tree_text(node)
    self.title
  end

  # Don't index carrousels
  def self.indexable?
    false
  end
  
  # Get display time in minutes
  def display_time_in_seconds
    read_attribute(:display_time_in_seconds) || 0
  end  
  
  # Set display time
  def display_time=(time)
    return unless time.is_a?(Array) and time.size == 2
    value = time[0].to_i; unit = time[1]
    self.display_time_in_seconds = ALLOWED_TIME_UNITS.include?(unit) ? value.send(unit) : 0
  end

  # Get human display time
  def display_time
    case
    when display_time_in_seconds < 60
      [display_time_in_seconds,                 'seconds']
    when display_time_in_seconds < 60*60
      [display_time_in_seconds/60,              'minutes']
    when display_time_in_seconds < (60*60*24)
      [display_time_in_seconds/(60*60),         'hours']
    when display_time_in_seconds < (30*(60*60*24))
      [display_time_in_seconds/(60*60*24),      'days']
    else 
      [display_time_in_seconds/(30*(60*60*24)), 'months']
    end    
  end

protected

  def remove_associated_content
    self.carrousel_items.destroy_all
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
      elsif (last_cycled + display_time_in_seconds.seconds) <= Time.now
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
