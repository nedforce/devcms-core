module SitemapsHelper

  # Returns the HTML for the sitemap (an unsorted list with clickable node titles)
  # up to a specified number of sublist levels.  
  def create_sitemap(levels = 6)
    items = current_site.accessible_content_children(:for_menu => true, :order => :position)
    unless items.empty?
      content_tag(:ul, items.map { |item| create_subitem(item, levels) }.join("\n"), :id => 'sitemap', :class => 'clearfix')
    else
      '&nbsp' # No menu if no first level items
    end
  end

  protected

  # Returns the HTML for a sublist of the sitemap (an unsorted list with clickable node titles)
  # up to a specified number of submenu levels.
  #
  # *arguments*
  # +item+ - The content node to create an unsorted list for.
  # +levels+ - The maximum of sublists.
  def create_subitem(item, levels)
    @current_level ||= 0
    subitems = item.node.accessible_content_children(:for_menu => true, :order => :position)
    if item.node.leaf? || subitems.empty? || @current_level == levels
      @current_level = 0 if @current_level == levels
      content = link_to(h(item.content_title), content_node_path(item.node), :title => h(item.content_title))
      content_tag(:li, content, :class => 'link')
    else
      @current_level += 1
      ul      = content_tag(:ul, subitems.map{|subitem| create_subitem(subitem, levels) }.join("\n"))
      content = link_to(h(item.content_title), content_node_path(item.node), :title => h(item.content_title))
      content_tag(:li, content + ul, :class => 'subitem')
    end
  end  
end