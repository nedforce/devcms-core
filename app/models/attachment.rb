# An Attachment is a content node that can describe and contain any kind
# of file. It has specified +acts_as_content_node+ from
# Acts::ContentNode::ClassMethods.
#
# If you want to attach an image and render it inline, then use the the Image
# content node instead of this one. If you want to attach an image and make it
# available for download, then use this Attachment.
#
# *Specification*
#
# Attributes
#
# * +content_type+ - The MIME type of the file.
# * +db_file+ - The binary file data.
# * +filename+ - The name of the file.
# * +height+ - The height of the image (if applicable).
# * +parent+ - The original version of the thumbnail (if applicable).
# * +size+ - The size of the file in bytes.
# * +thumbnail+ - The type of the thumbnail file (if applicable).
# * +thumbnais+ - An array with thumbnail versions of this attachment (if applicable).
# * +title+ - The title of the file.
# * +width+ - The width of the image (if applicable).
#
# Preconditions
#
# * Requires the presence of +db_file+.
# * Requires +db_file+ to be valid.
# * Requires +db_file+ to be between 1 byte and 5 Megabytes in size.
# * Requires the presence of +title+.
#
# Postconditions
#
# * Will destroy +thumbnail_attachment+ when the original attachment is destroyed.
#
class Attachment < ActiveRecord::Base
  acts_as_content_node({
    show_in_menu:            false,
    show_content_box_header: false
  }, {
    exclude: [:id, :created_at, :updated_at, :size, :height, :width, :db_file_id, :parent_id, :filename, :thumbnail, :content_type]
  })

  # This content type needs approval when created or altered by an editor.
  needs_editor_approval

  mount_uploader :file, AttachmentUploader

  # Clean the +filename+.
  before_validation :clean_filename

  # Store metadata
  before_validation :set_metadata

  validates :content_type, presence: true
  validates :size,         presence: true, numericality: { allow_nil: true }
  validates :height,                       numericality: { allow_nil: true }
  validates :width,                        numericality: { allow_nil: true }

  # The binary data of the attachment is stored in a separate +db_file+ model.
  belongs_to :db_file

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { maximum: 255 }
  validates_format_of :filename, with: /[a-z0-9\-_]+/i

  # Returns the file extension of this attachment or nil if it has none.
  def extension
    filename =~ /\./ ? filename.split('.').last : nil
  end

  # Returns the basename of this attachment.
  def basename
    if extension
      basename = filename.split('.')
      basename.pop
      basename.join('.')
    else
      filename
    end
  end

  # Returns the filename as the token for indexing.
  def content_tokens
    filename
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.official_publication')
  end

  def path_for_url_alias(node)
    basename.gsub(/[^a-z0-9\-_]/i, '-')
  end

  protected

  # Clean up the +filename+ for storage.
  def clean_filename
    if filename.present?
      cleaned_filename = cleaned_basename = basename.gsub(/[^a-z0-9\-_]/i, '-')
      cleaned_filename = "#{cleaned_basename}.#{extension.downcase}" if extension
      self.filename    = cleaned_filename
    end
  end

  def set_metadata
    if file?
      self.content_type ||= file.file.content_type || Mime::Type.lookup_by_extension(file.file.extension)
      self.size         ||= file.file.size
      self.filename     ||= file.file.original_filename
    end
  end
end
