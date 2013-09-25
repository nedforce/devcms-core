module Admin::CropperHelper

  def render_cropper(image, html_options = nil)
    html_options ||= {}
    html_options.merge!(:id => "image_cropper_#{image.id}")
    
    locals = { :image => image }  
      
    content_tag :div, html_options do
      if image.orientation == :vertical
        render :partial => 'cropper_vertical', :locals => locals
      else
        render :partial => 'cropper_horizontal', :locals => locals
      end
    end
  end

end
