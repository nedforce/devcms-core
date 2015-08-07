module Admin::CropperHelper
  def render_cropper(image, html_options = nil)
    html_options ||= {}
    html_options[:id] = "image_cropper_#{image.id}"

    content_tag :div, html_options do
      render partial: cropper_partial(image.orientation), locals: { image: image }
    end
  end

  def cropper_partial(orientation)
    orientation == :vertical ? 'cropper_vertical' : 'cropper_horizontal'
  end
end
