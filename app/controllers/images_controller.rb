class ImagesController < ApplicationController
  prepend_before_action :redirect_to_jpg, except: :show

  skip_before_action :confirm_destroy, :set_search_scopes, :set_private_menu, :find_accessible_content_children_for_menu, :set_rss_feed_url, :set_view_paths

  before_action :find_image, :set_image_format

  before_action :redirect_private, except: :show

  skip_after_action :increment_hits

  layout false

  caches_page :full, :sidebox, :header, :thumbnail, :banner, :big_header, :newsletter_banner

  def full
    render_image @image.file.full.path
  end

  def header
    render_image_data @image.resize!(size: "#{Image::HEADER_IMAGE_SIZE[:width]}x#{Image::HEADER_IMAGE_SIZE[:height]}", crop: true, upsample: true, quality: 90, format: @image_format)
  end

  def big_header
    render_image_data @image.resize!(size: "#{Image::HEADER_BIG_IMAGE_SIZE[:width]}x#{Image::HEADER_BIG_IMAGE_SIZE[:height]}", crop: true, upsample: true, quality: 90, format: @image_format)
  end

  def banner
    offset = @image.offset
    if @image.orientation == :vertical
      ratio  = (100.0 / Image::CONTENT_BOX_SIZE[:width].to_f)
      offset = 0 if offset.nil?
      offset = ((offset + (Image::CONTENT_BOX_SIZE[:height].to_f / 2)) * ratio) - 50
      offset = 0 if offset < 0
      resized_height = @image.calculate_other_dimension_with(width: 100)
      offset = resized_height - 100 if (resized_height - offset) < 100
    elsif @image.orientation == :horizontal
      offset = nil
    end

    render_image_data @image.resize!(size: "#{Image::CONTENT_BOX_SIZE[:width]}x#{Image::CONTENT_BOX_SIZE[:height]}", offset: offset, crop: true, upsample: false, quality: 80, format: @image_format)
  end

  def newsletter_banner
    render_image_data @image.resize!(size: "#{Image::NEWSLETTER_BANNER_SIZE[:width]}x", upsample: true, quality: 80, format: @image_format)
  end

  def thumbnail
    render_image_data @image.resize!(size: '100x100', crop: true, quality: 80, offset: @image.offset, upsample: true, format: @image_format)
  end

  def sidebox
    render_image_data @image.resize!(size: "#{Image::CONTENT_BOX_SIZE[:width]}x1024", quality: 90, format: @image_format)
  end

  def private_full
    full
  end

  def private_header
    header
  end

  def private_banner
    banner
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
    @image_format = %w(jpg jpeg gif png).include?(params[:format]) ? params[:format].to_sym : nil
    @image_format = :jpg if @image_format == :jpeg
  end

  def redirect_to_jpg
    unless params.key?(:format)
      redirect_to format: Image::DEFAULT_IMAGE_TYPE
    end
  end

  def redirect_private
    if !params[:action].include?('private_') && @image.node.private?
      redirect_to url_for(id: @image.id, action: "private_#{params[:action]}", format: @image_format)
    end
  end

  # Wrapper functions for render_image
  # def render_image(image_path); render_image(image_path, :file); end
  def render_image_data(image_data)
    render_image(image_data, :data)
  end

  # Render image file or data in different formats
  def render_image(image_data_or_file, type = :file)
    if @image_format
      respond_to do |format|
        # Public images may be cached by proxy servers
        expires_in(24.hours, public: true) unless @image.node.private?

        options = {
          type: Image::MIME_TYPES[@image_format],
          disposition: 'inline'
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
