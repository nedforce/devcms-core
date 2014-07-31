module DevcmsCore
  module ImageProcessingExtensions
    def file_path
      @file_path ||= file.try(:path)
    end

    def rmagick_image
      @rmagick_image ||= (file_path.present? ? ::Magick::Image::read(file_path).first : nil)
    end

    def orientation
      (rmagick_image.rows > rmagick_image.columns) ? :vertical : :horizontal
    end

    def calculate_other_dimension_with(options)
      options.symbolize_keys!
      raise ArgumentError, 'either :width or :height need to be specified' unless options[:width] || options[:height]

      h = rmagick_image.rows
      w = rmagick_image.columns

      if options[:width]
        (h * options[:width]) / w
      elsif options[:height]
        (w * options[:height]) / h
      end
    end

    # Resize this image.  Use the following options
    #
    # * +size+: size of the output image after the resize operation.  See the :+crop+ option for more details
    #   on exactly how this works.
    #
    # * +crop+: pass true to this option to make the ouput image exactly 
    #   the same dimensions as <tt>:size</tt>.  The default behaviour will resize the image without
    #   cropping any part meaning the image will be no bigger than the <tt>:size</tt>.  When <tt>:crop</tt>
    #   is non-false the final image is resized to fit as much as possible in the frame, and then crops it
    #   to make it exactly the dimensions declared by the <tt>:size</tt> parameter.
    #
    # * +upsample+: By default the image will never display larger than its original dimensions,
    #   no matter how large the :+size parameter is.  Pass +true+ to use this option to allow
    #   upsampling, disabling the default behaviour.
    #
    # * +padding+: This option will pad the around your image with a solid color to make it exactly the requested
    #   size.  Pass +true+, for the default of +white+, or give it a text or pixel color like <tt>"red"</tt> or
    #   <tt>color(255, 127, 0)</tt>.  This is like the opposite of the +crop+ option.  Instead of trimming the
    #   image to make it exactly the requested size, it will make sure the entire image is visible, but adds space
    #   around the edges to make it the right dimensions.
    #
    # * +stretch+: Set this option to true and the image will not preserve its aspect ratio.  The final image will
    #   stretch to fit the requested +size+.  The resulting image is exactly the size you ask for.
    #
    # * +format+: Sets the image format, e.g. 'jpg'
    #
    # Example:
    #
    #   image = MyImage.find(1)
    #   image.resize! :size => '100x75',
    #                 :crop => true
    #
    def resize!(options)
      options = options.symbolize_keys
      raise ArgumentError, ':size must be included in resize options' unless options[:size]

      # load image
      img = rmagick_image.dup

      # Find dimensions
      x, y = size_to_xy(options[:size])

      # prevent upscaling unless :usample param exists.
      unless options[:upsample]
        x = img.columns if x > img.columns
        y = img.rows    if y > img.rows
      end

      # Perform image resize
      case
      when options[:crop] && !options[:crop].is_a?(Hash) && img.respond_to?(:crop_resized!)
        # perform resize and crop
        scale_and_crop(img, [x, y], options[:offset])
      when options[:stretch]
        # stretch the image, ignoring aspect ratio
        stretch(img, [x, y])      
      else
        # perform the resize without crop
        scale(img, [x, y])      
      end

      if options[:format]
        img.format = options[:format].to_s.upcase
        img.strip!
      end

      options[:quality] ? img.to_blob { self.quality = options[:quality].to_i } : img.to_blob
    end

    def size_to_xy(size)
      if size.is_a?(Array) && size.size == 2
        size
      elsif size.to_s.include?('x')
        size.split('x').map(&:to_i)
      else
        [size.to_i, size.to_i]
      end
    end

    def scale(img, size)
      img.change_geometry!(size_to_xy(size).join('x')) do |cols, rows, _img|
        cols = 1 if cols < 1
        rows = 1 if rows < 1
        _img.resize!(cols, rows)
      end
    end

    def scale_and_crop(img, size, offset)
      width, height = size_to_xy(size)
      columns = img.columns
      rows = img.rows

      if width != columns || height != rows
        scale = [width / columns.to_f, height / rows.to_f].max
        img.resize!(scale * columns + 0.5, scale * rows + 0.5)
      end

      if width != columns || height != rows
        if offset.blank?
          img.crop!(Magick::CenterGravity, width, height, true)
        else
          if height == width
            # Crop based on original
            if columns > rows
              img.crop!(offset, 0, width, height, true) # Chop left/right
            else
              img.crop!(0, offset, width, height, true) # Chop up/down
            end
          else
            # Crop based on new dimensions
            if height > width
              img.crop!(offset, 0, width, height, true) # Chop left/right
            else
              img.crop!(0, offset, width, height, true) # Chop up/down
            end
          end
        end
      end

      img
    end

    def stretch(img, size)
      img.resize!(*size_to_xy(size))
    end
  end
end
