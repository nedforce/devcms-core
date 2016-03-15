# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Attachment+ objects.
class AttachmentsController < ApplicationController
  # Find the relevant attachment and skip node/sidebox loading.
  before_filter :find_attachment, only: :show

  # No layout should be rendered when an attachment is requested.
  layout false

  # Uploads an attachment to the user if the filename matches. If no filename is
  # given, then redirect to the correct filename for caching purposes.
  def show
    if (Settler[:search_luminis_crawler_ips] || []).include?(request.remote_ip)
      render file: '/attachments/show.html.haml'
    else
      set_cache_control
      # Upload file to user
      upload_file
    end
  end

  protected

  def upload_file
    if File.exist?(@attachment.file.path)
      send_file(@attachment.file.path,
                type:        @attachment.content_type,
                filename:    @attachment.filename,
                disposition: 'attachment')
    else
      raise ActionController::RoutingError.new('File not found')
    end
  end

  def find_attachment
    @attachment = @node.content
  end

  def set_cache_control
    # This can be cached by proxy servers
    expires_in 24.hours, public: true
  end
end
