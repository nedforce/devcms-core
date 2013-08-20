class ImagesController < ApplicationController
  
  prepend_before_filter :redirect_to_jpg,  :except => :show
  
  skip_before_filter :confirm_destroy, :set_search_scopes, :set_private_menu, :find_accessible_content_children_for_menu, :set_rss_feed_url, :set_view_paths
  
  before_filter :find_image, :set_image_format
  
  before_filter :redirect_private, :except => :show
  
  skip_after_filter :increment_hits

  layout false

  caches_page :full, :sidebox, :header, :thumbnail, :content_box_header, :big_header, :newsletter_banner

  def full
    render_image @image.file.full.path
  end

  def header
    render_image_data @image.resize!(:size => "#{Image::HEADER_IMAGE_SIZE[:width]}x#{Image::HEADER_IMAGE_SIZE[:height]}", :crop => true, :upsample => true, :quality => 90, :format => @image_format)
  end
  
  def big_header
    render_image_data @image.resize!(:size => "#{Image::HEADER_BIG_IMAGE_SIZE[:width]}x#{Image::HEADER_BIG_IMAGE_SIZE[:height]}", :crop => true, :upsample => true, :quality => 90, :format => @image_format)
  end

  def content_box_header
    render_image_data @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x#{Image::CONTENT_BOX_SIZE[:height]}", :offset => @image.offset, :crop => true, :upsample => false, :quality => 80, :format => @image_format)
  end

  def newsletter_banner
    render_image_data @image.resize!(:size => "#{Image::NEWSLETTER_BANNER_SIZE[:width]}x#{Image::NEWSLETTER_BANNER_SIZE[:height]}", :crop => true, :upsample => false, :quality => 80, :format => @image_format)
  end

  def thumbnail
    offset = @image.offset
    is_header = @image.node.parent.content_type == 'NewsItem' && @image.node.previous_item.blank?
    if @image.orientation == :vertical && is_header
      ratio  = (100.0/Image::CONTENT_BOX_SIZE[:width].to_f)
      offset = 0 if offset.nil?
      offset = ((offset + (Image::CONTENT_BOX_SIZE[:height].to_f/2)) * ratio) - 50
      offset = 0 if offset < 0
      resized_height = @image.calculate_other_dimension_with(:width => 100)
      offset = resized_height - 100 if (resized_height - offset) < 100
    elsif @image.orientation == :horizontal && is_header
      offset = nil
    end

    render_image_data @image.resize!(:size => "100x100", :crop => true, :quality => 80, :offset => offset, :upsample => true, :format => @image_format)
  end

  def sidebox
    render_image_data @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x1024", :quality => 90, :format => @image_format)
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

  def set_image_format
    @image_format = ['jpg', 'jpeg', 'gif', 'png'].include?(params[:format]) ? params[:format].to_sym : nil
    @image_format = :jpg if @image_format == :jpeg
  end

  def redirect_to_jpg
    unless params.has_key?(:format)
      redirect_to :format => Image::DEFAULT_IMAGE_TYPE
    end
  end

  def redirect_private
    if !params[:action].include?("private_") && @image.node.private?
      redirect_to url_for(:id => @image.id, :action => "private_#{params[:action]}", :format => @image_format )
    end
  end
  
  # Wrapper functions for render_image
  # def render_image(image_path); render_image(image_path, :file); end
  def render_image_data(image_data); render_image(image_data, :data); end

  # Render image file or data in diferent formats
  def render_image image_data_or_file, type = :file
    if @image_format
      respond_to do |format|
        headers['Cache-Control'] = (@image.node.private? ? 'private' : 'public') # this can be cached by proxy servers

        options = {
          :type => Image::MIME_TYPES[@image_format],
          :disposition => 'inline'
        }

        format.send(@image_format) do
          if type == :data
            send_data image_data_or_file, options
          elsif type == :file
            send_file image_data_or_file, options
          end         
        end
      end      
    end
  end
end
