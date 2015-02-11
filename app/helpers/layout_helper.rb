module LayoutHelper
  def render_representations(target)
    partials        = ''
    node            = (@node || current_site)

    return unless node.own_or_inherited_layout_variant[target].present?  

    partial         = '/layouts/partials/' + node.own_or_inherited_layout_variant[target]['representation']
    inheritable     = node.own_or_inherited_layout_variant[target]['inheritable'].nil? || node.own_or_inherited_layout_variant[target]['inheritable']
    representations = node.find_content_representations(target, inheritable)

    representations.each do |element|
      next unless element.content_partial.present?

      if element.custom_type.present?
        render_helper = node.own_or_inherited_layout.custom_representations[element.custom_type]["helper"]
        partials += send(render_helper || "render_#{element.custom_type}") || ""
      else
        partials << render(:partial =>  partial, :locals => {  :node => element.content, :parent => element.parent, :partial => element.content_partial, :sidebox_title => element.title, :content_box_color => nil, :last => element == representations.last })
      end
    end
    partials
  end

  def render_sub_menu
    unless @node.blank? || @node.root?
      render :partial => '/layouts/partials/sub_menu'
    end
  end

  def render_private_menu
    if @private_menu_items.present?
      render :partial => '/layouts/partials/private_menu'
    end
  end

  def render_related_content
    return if controller_name == 'shares'

    if @node && @node.content_type_configuration[:has_own_content_box] && !((@node.content_class == Page || @node.content_class <= Section) && @node.categories.empty?)
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

  def toggable_section_link(dom_id, link_or_link_title, options = {})
    link_options = { :id => "toggle_section_#{dom_id}", :class => 'toggable_section_link' }

    if link_or_link_title.is_a?(Link)
      html = link_to_content_node(truncate(h(link_or_link_title.content_title), :length => 60), link_or_link_title, {}, link_options)
    else
      html = content_tag options[:element_type] || :span, link_or_link_title, link_options
    end

    return html
  end

  def unemptynize(string, default)
    if string && !string.empty?
      string
    else
      default
    end
  end
end
