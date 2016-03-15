module MenuHelper

  # Returns the html for the double-level main menu.
  def create_main_menu
    string_cache(:main_menu_for_site => current_site.id) do
      if top_level_main_menu_items.any?
        content_tag(:ul, top_level_main_menu_items.map { |item, sub_items| create_main_menu_item(item, sub_items.keys) }.join("\n").html_safe, :class => 'clearfix main-menu')
      else
        raw '&nbsp;'
      end
    end
  end

  # Returns the HTML for the multi-level sub menu.
  def create_sub_menu(self_and_ancestor_ids, top_sub_menu_items, show_private_items_in_sub_menu)
    sub_menu_content = top_sub_menu_items.map do |item|
      create_sub_menu_item(item, self_and_ancestor_ids[1..-1], show_private_items_in_sub_menu, :class => 'top-level')
    end.join("\n").html_safe

    content_tag(:ul, sub_menu_content, :class => 'sub-menu')
  end

  protected

  def top_level_main_menu_items
    @top_level_main_menu_items || begin
      menu_scope = current_site.descendants(to_depth: Devcms.main_menu_depth).accessible.is_public.shown_in_menu.reorder(:position)
      top_level_main_menu_items = current_site.closure_for(menu_scope).values.first
    end
  end

  # Returns the HTML for a main menu item.
  #
  # *arguments*
  # +node+ - The node to create a main menu item for.
  def create_main_menu_item(node, children)
    template_color = node.own_or_inherited_layout_configuration['template_color']

    if children.empty?
      content_tag(:li, create_menu_link(node, :class => 'main-menu-link no-children'), :class => template_color)
    else
      content_tag(:li, :class => template_color) do
        [ create_menu_link(node, :class => 'main-menu-link'),
          create_main_menu_sub_menu(children)
        ].join.html_safe
      end
    end
  end

  def create_main_menu_sub_menu children
    content_tag(:div, :class => 'sub-menu-wrapper') do
      content_tag(:ul, :class => 'sub-menu') do
        children.map { |child| content_tag(:li, create_menu_link(child, :class => 'sub-menu-link')) }.join("\n").html_safe
      end
    end
  end

  # Returns the HTML for a sub menu item.
  #
  # *arguments*
  # +node+ - The node to create a sub menu item for.
  # +self_and_ancestors_except_root_ids+ - The list of ids of nodes that are ancestors of (except the root node) or equal to the node
  # for which the submenu is being built.
  # +show_private_items_in_sub_menu+ - True if private items should be shown, otherwise false.
  # +options+ - Additional HTML attributes to be set on the sub menu item.
  def create_sub_menu_item(node, self_and_ancestors_except_root_ids, show_private_items_in_sub_menu, options = {})
    if show_private_items_in_sub_menu
      if current_user_has_any_role?(node)
        sub_menu_items = node.children.accessible.shown_in_menu.reorder(:position)
      else
        sub_menu_items = node.children.accessible.shown_in_menu.reorder(:position).select do |sub_menu_item|
          sub_menu_item.public? || current_user_has_any_role?(sub_menu_item)
        end
      end
    else
      sub_menu_items = node.children.accessible.is_public.shown_in_menu.reorder(:position)
    end

    has_sub_menu_items = sub_menu_items.any?

    options[:class] = options[:class] ? "#{options[:class]} parent" : "parent" if has_sub_menu_items

    unless self_and_ancestors_except_root_ids.include?(node.id)
      content_tag(:li, create_menu_link(node, :class => 'sub_menu_link'), options)
    else
      classes = %w( sub_menu_link expanded )
      classes << 'current' if node == @node || (node.content.is_a?(Section) && node.content.frontpage_node_id == @node.id)

      content = create_menu_link(node, :class => classes)

      if has_sub_menu_items
        content += content_tag(:ul, sub_menu_items.map { |item| create_sub_menu_item(item, self_and_ancestors_except_root_ids, show_private_items_in_sub_menu) }.join("\n").html_safe)
      end

      options[:class] = options[:class] ? [options[:class], 'expanded'].compact : 'expanded'
      content_tag(:li, content, options)
    end
  end

  def create_menu_link(node, options = {})
    link_to_node(h(node.menu_title), node, {}, { title: h(node.menu_title) }.merge(options))
  end
end
