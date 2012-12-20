module ReadspeakerHelper

  # Generates a button/link for readspeaker. A readspeaker id needs to be specified if multiple readspeak buttons are used on a page.
  def readspeaker_button(options = {})
    if Settler[:readspeaker_cid].present?
      rid = options.delete(:rid)
      link_class = [ options.delete(:class), 'readspeaker_link' ].compact.join(' ')
      readspeaker_url = readspeaker_url_for(request.url, { :rid => rid }.merge(options)).html_safe

      content_tag(:div, :class => 'readspeaker_button') do
        (image_tag('icons/sayit.png', :class => 'icon', :alt => '', :title => t('application.sayit_title')) +
        (link_to(t('application.sayit'), readspeaker_url, { :title => t('application.sayit_title'), :class => link_class, :rel => 'nofollow' }.merge(options))) unless @node && (@node.hidden? || @node.private? || !@node.publishable?))
      end
    end
  end

  # Generates a block which will be read by readspeaker. For multiple blocks on a page specify a readspeaker_id.
  def readspeaker(rid = nil, &block)
    content = capture(rid, &block)

    html = <<-html
    <!-- RSPEAK_START -->
    #{content}
    <!-- RSPEAK_STOP -->
    html

    html = html.html_safe
    (rid.blank? ? html : content_tag(:div, html, :id => "readspeaker_block_#{rid}"))
  end

  # Returns a url to readspeaker.
  def readspeaker_url_for(target_url, options = {})
    url  = "http://app.readspeaker.com/cgi-bin/rsent?customerid=#{Settler[:readspeaker_cid]}"
    url << "&amp;readid=readspeaker_block_#{options[:rid]}" if options[:rid].present?
    if options[:lang].present? && options[:lang] != 'nl'
      url << "&amp;lang=#{options[:lang]}"
    else
      url << "&amp;lang=nl_nl"
    end
    url << "&amp;url=#{CGI.escape(target_url)}"
    url.html_safe
  end
end
