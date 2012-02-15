module AttachmentsHelper
  # Returns the proper attachment icon based on the given +attachment+ extension.
  def attachment_icon(attachment, options = {})
    case attachment.extension
    when 'jpg', 'jpeg', 'gif', 'png'
      file_name = 'image.png'
    when 'doc', 'docx'
      file_name = 'word.png'
    when 'xls', 'xlsx', 'csv'
      file_name = 'excel.png'
    when 'ppt', 'pptx'
      file_name = 'powerpoint.png'
    when 'tar', 'zip', 'rar', 'gz'
      file_name = 'compressed.png'
    when 'pdf', 'ps'
      file_name = 'pdf.png'
    else
      file_name = 'default.png'
    end
    image_tag("icons/mime_types/#{file_name}", { :alt => attachment.content_type }.merge(options))
  end
end
