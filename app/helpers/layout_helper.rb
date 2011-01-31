module LayoutHelper
  def render_representations(target)
    partials        = ''
    node            = (@node || current_site)
    partial         = '/layouts/partials/' + node.own_or_inherited_layout_variant[target]['representation']
    inhertiable     = node.own_or_inherited_layout_variant[target]['inheritable'].nil? || node.own_or_inherited_layout_variant[target]['inheritable']
    representations = node.find_content_representations(target, current_user, inhertiable)

    representations.each do |element|
      if element.custom_type.present?
        render_helper = node.own_or_inherited_layout.custom_representations[element.custom_type]["helper"]
        partials += send(render_helper || "render_#{element.custom_type}") || ""
      else
        partials << render(:partial =>  partial, :locals => {  :node => element.content, :parent => element.parent, :partial => element.content_partial, :sidebox_title => element.title, :content_box_color => nil })
      end
    end
    partials
  end

  def render_sub_menu
    unless @node.nil? || @node.root?
      create_sub_menu
    end
  end

  def render_private_menu
    if @private_menu_items.present?
      render :partial => '/layouts/partials/private_menu'
    end
  end

  def render_related_content
    if @node && @node.content_type_configuration[:has_own_content_box] && !((@node.content_type == 'Page' || @node.content_type == 'Section') && @node.categories.empty?)
      custom_partial = @node.own_or_inherited_layout.custom_representations["related_content"]["content_partial"] || 'related_content'
      render :partial => '/layouts/partials/content_box',
             :locals  => {
                  :node              => @node,
                  :parent            => @node,
                  :partial           => custom_partial,
                  :sidebox_title     => I18n.t("#{@node.content_type.tableize}.related_content"),
                  :content_box_color => @node.own_or_inherited_layout_configuration['template_color']
             }
    end
  end
end