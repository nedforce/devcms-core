class ImagesController < ApplicationController
  
  prepend_before_filter :redirect_to_jpg,  :except => :show
  
  skip_before_filter :confirm_destroy, :set_search_scopes, :set_private_menu, :find_accessible_content_children_for_menu, :set_rss_feed_url, :set_view_paths
  
  before_filter :find_image
  
  before_filter :redirect_private, :except => :show
  
  skip_after_filter :increment_hits

  layout false

  caches_page :full, :sidebox, :header, :thumbnail, :content_box_header, :big_header

  def full
    render_jpg_image @image.file.full.path
  end

  def header
    render_jpg_image_data @image.resize!(:size => "#{Image::HEADER_IMAGE_SIZE[:width]}x#{Image::HEADER_IMAGE_SIZE[:height]}", :crop => true, :upsample => true, :quality => 90, :format => 'jpg')
  end
  
  def big_header
    render_jpg_image_data @image.resize!(:size => "#{Image::HEADER_BIG_IMAGE_SIZE[:width]}x#{Image::HEADER_BIG_IMAGE_SIZE[:height]}", :crop => true, :upsample => true, :quality => 90, :format => 'jpg')
  end

  def content_box_header
    render_jpg_image_data @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x#{Image::CONTENT_BOX_SIZE[:height]}", :offset => @image.offset, :crop => true, :upsample => false, :quality => 80, :format => 'jpg')
  end

  def thumbnail
    render_jpg_image_data @image.resize!(:size => "100x100", :crop => true, :quality => 80, :offset => @image.offset, :upsample => true, :format => 'jpg')
  end

  def sidebox
    render_jpg_image_data @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x1024", :quality => 90, :format => 'jpg')
  end

  def private_full
    full
  end

  def private_header
    header
  end

  def private_content_box_header
    content_box_header
  end

  def private_thumbnail
    thumbnail
  end

  def private_sidebox
    sidebox
  end

  # Aliases +full+ as +show+.
  def show
    full
  end

protected

  def find_image
    @image = Image.accessible.find(params[:id])
  end

  def redirect_to_jpg
    unless params.has_key?(:format) && params[:format] == 'jpg'
      redirect_to :format => 'jpg'
    end
  end

  def redirect_private
    if !params[:action].include?("private_") && @image.node.private?
      redirect_to url_for(:id => @image.id, :action => "private_#{params[:action]}", :format => 'jpg' )
    end
  end
  
  def render_jpg_image(image_path)
    respond_to do |format|
      headers['Cache-Control'] = (@image.node.private? ? 'private' : 'public') # this can be cached by proxy servers
      format.any do
        send_file(image_path, :type => 'image/jpeg', :disposition => 'inline')   
      end      
    end
  end  

  def render_jpg_image_data(image_data)
    respond_to do |format|
      headers['Cache-Control'] = (@image.node.private? ? 'private' : 'public') # this can be cached by proxy servers
      format.jpg do
        send_data(image_data, :type => 'image/jpeg', :disposition => 'inline')   
      end      
    end
  end
end
