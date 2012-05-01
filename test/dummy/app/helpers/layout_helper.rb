extension_of DevcmsCore

module LayoutHelper
  
  def render_skype_box
    if @node.present? && @node.content_type == 'Product' && Settler[:products_with_skype_box].include?(@node.content.external_id)
      render :partial => '/layouts/partials/skype_box'
    end
  end
  
end