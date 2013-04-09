module Admin::CropperHelper

  def render_cropper(image, html_options = nil)
    html_options ||= {}
    html_options.merge!(:id => "image_cropper_#{image.id}")

    is_header = image.node.parent.content_type == 'NewsItem'
    locals = { :image => image, :is_header => is_header }  

    content_tag :div, html_options do
      if image.orientation == :vertical || is_header
        render :partial => 'cropper_vertical', :locals => locals
      else
        render :partial => 'cropper_horizontal', :locals => locals
      end
    end
  end

end
