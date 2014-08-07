module AttachmentsHelper
  # Returns the proper attachment icon based on the given +attachment+ extension.
  def attachment_icon(attachment, options = {})
    image_tag("icons/mime_types/#{icon_name(attachment.extension)}.png", { alt: '' }.merge(options))
  end

  protected

  def icon_name(extension)
    case extension
    when 'jpg', 'jpeg', 'gif', 'png', 'bmp', 'tif', 'tiff'
      'image'
    when 'doc', 'docx', 'odt'
      'word'
    when 'xls', 'xlsx', 'csv', 'ods'
      'excel'
    when 'ppt', 'pptx', 'pps', 'ppsx', 'odp'
      'powerpoint'
    when 'tar', 'zip', 'rar', 'gz'
      'compressed'
    when 'pdf', 'ps'
      'pdf'
    else
      'default'
    end
  end
end
