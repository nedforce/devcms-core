class ImagesController < ApplicationController
  
  prepend_before_filter :redirect_to_jpg,  :except => :show
  
  skip_before_filter :confirm_destroy

  skip_before_filter :set_search_scopes
  
  skip_before_filter :set_private_menu
  
  skip_before_filter :find_accessible_content_children_for_menu
  
  skip_before_filter :set_rss_feed_url
  
  before_filter :find_image
  
  before_filter :redirect_private, :except => :show
  
  skip_after_filter :increment_hits

  layout false

  caches_page :full, :sidebox, :header, :thumbnail, :content_box_header, :big_header

  def full
    @image.resize!(:size => '800x500', :quality => 90)
    render_image
  end

  def header
    @image.resize!(:size => "#{Image::HEADER_IMAGE_SIZE[:width]}x#{Image::HEADER_IMAGE_SIZE[:height]}", :crop => true, :upsample => true, :quality => 90)
    render_image
  end
  
  def big_header
    @image.resize!(:size => "#{Image::HEADER_BIG_IMAGE_SIZE[:width]}x#{Image::HEADER_BIG_IMAGE_SIZE[:height]}", :crop => true, :upsample => true, :quality => 90)
    render_image
  end

  def content_box_header
    @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x#{Image::CONTENT_BOX_SIZE[:height]}", :vertical_offset => @image.vertical_offset, :crop => true, :upsample => true, :quality => 80)
    render_image
  end

  def thumbnail
    if @image.orientation == :vertical 
      @image.resize!(:size => "100x100", :crop => true, :quality => 80, :vertical_offset => @image.vertical_offset, :upsample => true)
    else
      @image.resize!(:size => "100x100", :crop => true, :quality => 80)
    end
    render_image
  end

  def sidebox
    @image.resize!(:size => "#{Image::CONTENT_BOX_SIZE[:width]}x1024", :quality => 90)
    render_image
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
    @image = Image.select_all_columns.find(params[:id])
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

  def render_image
    respond_to do |format|
      headers['Cache-Control'] = (@image.node.private? ? 'private' : 'public') # this can be cached by proxy servers
      format.jpg { render_flex_image(@image) }
    end
  end
end
