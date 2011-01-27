class AttachmentsController < ApplicationController
  # Find the relevant attachment and skip node/sidebox loading.
  before_filter :find_attachment, :only => [ :show, :private ]

  # No layout should be rendered when an attachment is requested.
  layout false

  #set caching
  #caches_page :show

  # Uploads an attachment to the user if the filename matches. If no filename is
  # given, then redirect to the correct filename for caching purposes.
  def show
    if DevCMS.search_configuration[:luminis].try(:has_key?, :luminis_crawler_ips) and DevCMS.search_configuration[:luminis][:luminis_crawler_ips].include?(request.remote_ip)
      # Render metadata view.
    elsif params.has_key?(:basename)
      # Only upload this to the user if it is what he expects.
      upload_file
    else
      action = @attachment.node.is_hidden? ? :private : :show
      if @attachment.extension
        redirect_to url_for(:id => @attachment.id, :action => action, :format => @attachment.extension, :basename => @attachment.basename)
      else
        redirect_to url_for(:id => @attachment.id, :action => action, :basename => @attachment.basename)
      end
    end
  end

  def private
    upload_file('private')
  end

protected

    def upload_file(cache_control="public")
      if @attachment.filename == "#{params[:basename]}.#{params[:format]}" || @attachment.filename == params[:basename]
        headers['Cache-Control'] = cache_control # this can be cached by proxy servers
        send_file(@attachment.create_temp_file, 
                  :type => @attachment.content_type, 
                  :filename => @attachment.filename, 
                  :length => @attachment.size, 
                  :disposition => 'attachment', 
                  :stream => true)
      else
        respond_to do |format|
          format.html { render :nothing => true, :status => :not_found }
        end
      end
    end

    def find_attachment
      @attachment = @node.approved_content
    end
end

