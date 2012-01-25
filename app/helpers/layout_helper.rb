module LayoutHelper
  def render_representations(target)
    partials        = ''
    node            = (@node || current_site)
    partial         = '/layouts/partials/' + node.own_or_inherited_layout_variant[target]['representation']
    inheritable     = node.own_or_inherited_layout_variant[target]['inheritable'].nil? || node.own_or_inherited_layout_variant[target]['inheritable']
    representations = node.find_content_representations(target, inheritable)

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

  def text_link_toggable_section(dom_id, link_id, link)
    html = link_to_content_node(truncate(h(link.content_title), :length => 60), link, {}, {:id => link_id})
    html << javascript_tag(<<-EOS
      Element.observe('#{link_id}', 'click', function (event) {
        Effect.toggle('#{dom_id}', 'appear', {duration: 0.5})
        Element.toggleClassName('#{link_id}', 'minus_icon')
        Event.stop(event)
      })
    document.observe('dom:loaded', function () { Element.hide('#{dom_id}') } ); 
EOS
)
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
