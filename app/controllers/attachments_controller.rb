class AttachmentsController < ApplicationController
  # Find the relevant attachment and skip node/sidebox loading.
  before_filter :find_attachment, :only => [ :show ]

  # No layout should be rendered when an attachment is requested.
  layout false

  # Uploads an attachment to the user if the filename matches. If no filename is
  # given, then redirect to the correct filename for caching purposes.
  def show
    if DevCMS.search_configuration[:luminis].try(:has_key?, :luminis_crawler_ips) and DevCMS.search_configuration[:luminis][:luminis_crawler_ips].include?(request.remote_ip)
      render :file => '/attachments/show.html.haml'
    else
      # Upload file to user
      upload_file(!@attachment.node.visible? ? 'private': 'public')
    end
  end

  protected

  def upload_file(cache_control = 'public')
    headers['Cache-Control'] = cache_control # This can be cached by proxy servers
    send_file(@attachment.create_temp_file, 
              :type        => @attachment.content_type, 
              :filename    => @attachment.filename, 
              :length      => @attachment.size, 
              :disposition => 'attachment', 
              :stream      => true)
  end

  def find_attachment
    @attachment = @node.content
  end
end
