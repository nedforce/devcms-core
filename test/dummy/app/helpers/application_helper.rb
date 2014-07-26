module ApplicationHelper
  def content_box_icon_alt_for(node)
    return if node.content_box_icon.blank?

    case node.content_box_icon
    when 'agenda'
      'Icoon van persoon met agenda'
    when 'bestuurenorg'
      'Icoon van burgemeester en organisatie'
    when 'bewoners'
      'Icoon van een huis met bewoner'
    when 'bezoekers'
      'Icoon van bezoekers'
    when 'contact'
      'Icoon van telefonerend persoon'
    when 'deraad'
      'Icoon van de gemeenteraad'
    when 'digitaalloket'
      'Icoon van een computerend persoon'
    when 'meestgelezen'
      'Icoon van een persoon die zijn favoriete pagina bekijkt'
    when 'nieuwopdesite'
      'Icoon van een persoon die de nieuwste content bekijkt'
    when 'nieuws'
      'Icoon van een persoon die het nieuws bekijkt'
    when 'ondernemers'
      'Icoon van ondernemers'
    when 'poll'
      'Icoon van een persoon die een poll invult'
    when 'uitgelicht'
      'Icoon van een persoon die belangrijke content bekijkt'
    end
  end

  def theme_link(theme, class_name)
    if theme.number_of_reports > 0
      "<tr class=\"#{class_name}\"><td class=\"title\">#{link_to_content_node(theme.title, theme)}</td><td>#{theme.number_of_reports}</td></tr>"
    else
      "<tr class=\"#{class_name}\"><td class=\"title\">#{theme.title}</td><td></td></tr>"
    end
  end

  def report_button(alt = nil, &block)
    concat(content_tag(:div, :class => 'article') { image_tag('icons/news_item.png', :class => 'icon', :alt => alt) + capture(&block) })
  end
end
