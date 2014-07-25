module IconHelper
  def icon_tag name, options = {}
    options[:class] = ["deventer-icon-#{name}", options[:class]].compact
    content_tag :span, '', options
  end

  def top_task_icon_tag name, options = {}
    options[:data] = options[:data] ? options.data.merge!({ icon: name }) : { icon: name }
    content_tag :span, '', options
  end

  def icon_tag_link_to icon_name, url, options = {}
    title = options.delete :title
    icon_options = options.delete(:icon_options) || {}
    link_to [icon_tag(icon_name, icon_options), title].compact.join(' ').html_safe, url, options
  end
end
