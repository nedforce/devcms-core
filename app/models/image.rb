# This model is used to represent a image.
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the image.
# * +data+ - The binary image data.
# * +offset+ - The offset used when cropping the image to function as a header image for a context box.
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
class Image < ActiveRecord::Base
  include DevcmsCore::ImageProcessingExtensions

  CONTENT_BOX_SIZE        = { height:  93, width: 230 }
  HEADER_IMAGE_SIZE       = { height: 135, width: 726 }
  HEADER_BIG_IMAGE_SIZE   = { height: 190, width: 980 }
  NEWSLETTER_BANNER_SIZE  = { height: 118, width: 540 }

  MIME_TYPES = {
    png: 'image/png',
    jpg: 'image/jpeg',
    gif: 'image/gif',
  }

  DEFAULT_IMAGE_TYPE = :jpg

  # An +Image+ can be a carrousel item
  has_many :carrousel_items, as: :item, dependent: :destroy

  # Carrierwave uploader
  mount_uploader :file, ImageUploader

  # Adds content node functionality to images.
  acts_as_content_node({
    :available_content_representations => ['content_box'],
    :show_in_menu => false,
    :show_content_box_header => false
  }, {
    :exclude => [ :id, :created_at, :updated_at, :data ]
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  # See the preconditions overview for an explanation of these validations.
  validates :title,           presence: true, length: { maximum: 255 }
  validates :file,            presence: true
  validates :alt,                             length: { maximum: 255 }
  validates :show_in_listing, inclusion: { in: [false, true], allow_nil: true }

  validates_format_of       :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix, :allow_blank => true

  validates :offset, numericality: { greater_than_or_equal: 0, only_integer: true, allow_blank: true }

  # Join instead of include to ensure the default scopes select is still applied.
  scope :accessible, ->{ joins(:node).merge(Node.accessible) }

  # Ensure +url+ is correct.
  before_validation :prepend_http_to_url

  after_paranoid_delete :remove_associated_content

  # Never embed binary data in XML for images.
  alias_method :to_xml_with_data, :to_xml

  def to_xml(options = {})
    except = options[:except].nil? ? [] : [options[:except]].flatten
    to_xml_with_data(options)
  end

  # Returns the alt value as the token for indexing.
  def content_tokens
    alt
  end

protected

  # Prepends 'http://' to +url+ if it is not present.
  def prepend_http_to_url
    self.url = "http://#{url}" unless url.blank? || url.starts_with?('http://') || url.starts_with?('https://')
  end

  def remove_associated_content
    self.carrousel_items.destroy_all
  end
end
