# This model is used to represent a image.
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the image.
# * +data+ - The binary image data.
# * +vertical_offset+ - The vertical offset used when cropping the image to function as a header image for a context box.
# * +alt+ - The alt text (HTML attribute)
# * +description+ - The description of the image.
# * +url+ - The URL of the image.
# * +is_for_header+ - Whether the image is a header image or not.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +data+.
# * Requires +data+ to contain a valid image.
# 
# Child/parent type constraints
# 
# * An Image does not accept any child nodes.
# * An Image can only be inserted into Page or NewsItem nodes.
#
class Image < FlexImage::Model

  CONTENT_BOX_SIZE = { :height => 93, :width => 230 }

  # An +Image+ can be a carrousel item
  has_many :carrousel_items, :as => :item, :dependent => :destroy  
  
  # This is needed to be able to load images from a YAML-ized version of the ActiveRecord,
  # otherwise FlexImage won't recognize it.
  self.require_image_data = false
  
  # Adds content node functionality to images.
  acts_as_content_node({
    :available_content_representations => ['content_box'],
    :show_in_menu => false,
    :show_content_box_header => false
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval
  
  # Set image size to max 1024x1024 on creation.
  pre_process_image :size => '1024x1024', :quality => 95
  
  # Ensure +url+ is correct.
  before_validation :prepend_http_to_url 

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :title, :data
  validates_length_of       :title, :in => 2..255, :allow_blank => true
  validates_length_of       :alt,   :in => 0..255
  validates_format_of       :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :allow_blank => true
  validates_numericality_of :vertical_offset, :only_integer => true, :allow_blank => true, :greater_than_or_equal => 0 

  # Return generated alt if attribute isn't set.
  def alt
    self.attribute_present?(:alt) ? super : "#{I18n.t('images.image_of')}: #{self.title}"
  end

  # Never embed binary data in XML for images.
  alias_method :to_xml_with_data, :to_xml

  def to_xml(options = {})
    except = options[:except].nil? ? [] : [options[:except]].flatten
    to_xml_with_data(options.merge(:except => (except << :data)))
  end

  # Returns the alt value as the token for indexing.
  def content_tokens
    alt
  end

  def orientation
    (send(:rmagick_image).rows > send(:rmagick_image).columns) ? :vertical : :horizontal
  end

  # TODO: Documentation
  def height_at_width(width)
    h = send(:rmagick_image).rows
    w = send(:rmagick_image).columns
    width ||= w
    return (h * width) / w
  end

  protected

  # Prepends 'http://' to +url+ if it is not present.
  def prepend_http_to_url 
    self.url = "http://#{url}" unless url.blank? || url.starts_with?("http://") || url.starts_with?("https://")
  end
end
