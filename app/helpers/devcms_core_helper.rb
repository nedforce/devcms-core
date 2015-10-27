module DevcmsCoreHelper
  # Use the asset path for images, as we have our own image controller
  def image_path(*args)
    asset_path(*args)
  end

  def content_box_title_for(node)
    (node.content.respond_to?(:custom_content_box_title) && node.content.custom_content_box_title) ||
      (node.content_box_title.present? && node.content_box_title) || node.content.title
  end

  # Creates div elements containing the various flash messages, if any are set.
  # For each type of flash message (error, warning, notice, etc.), a separate
  # div is created. The class of each div is set to <tt>flash type</tt>, where
  # type is the type of the flash message.
  def yield_flash
    flash.keys.map do |key|
      content_tag(:div, class: "flash #{key}") do
        content_tag(:p, image_tag("icons/#{key}.png", class: 'icon', alt: key) + flash[key].to_s)
      end
    end.join.html_safe
  end

  # Creates the breadcrumbs element, which displays links to all the node's
  # ancestors.
  #
  # See documentation of +bread_crumbs_track_for+ for more information.
  def bread_crumbs_for(node, options = {})
    if @category.blank? && node.content_type != 'ProductCatalogue'
      string_cache(breadcrumbs_for_node: node.id, last_updated_at: node.path.maximum(:updated_at)) do
        build_bread_crumbs_for(node, options)
      end
    else
      build_bread_crumbs_for(node, options)
    end
  end

  def build_bread_crumbs_for(node, options = {})
    crumb_track = bread_crumbs_track_for(node, options)
    content_tag(:div, crumb_track.html_safe, class: 'bread_crumbs') if crumb_track.present?
  end

  # Creates the breadcrumbs element, which displays links to all the node's
  # ancestors.
  #
  # *arguments*
  # +node+ - The node for which breadcrumbs should be created. It will add all
  #          ancestors to it.
  # +options+ A hash with breadcrumb and link options:
  # :include_root: Include the root node in the path
  # :minimum_crumbs: The number of crumbs that should be in the path
  # :separator: The seperator between two crumbs
  # :popup_window: Link option: when clicked on a crumb, it will open in a new
  #                             window (using JavaScript).
  # :skip_link_self: Link option: Don't create a link for +node+. Useful when a
  #                               node is invisible or unapproved.
  # :suffix: A tree that follows the node, e.g. a category of a
  #          product catalogue.
  def bread_crumbs_track_for(node, options = {})
    options = { minimum_crumbs: 1, separator: ' &gt; ', include_root: true }.merge(options)

    host = options.delete :host

    crumb_track = String.new
    crumb_nodes = node.self_and_ancestors.reorder(:ancestry_depth)
    crumb_nodes.shift unless node.containing_site.root?
    crumb_nodes.shift unless options[:include_root]
    # Remove frontpage node to prevent semingly double crumbs
    frontpage_candidate = crumb_nodes[-2]
    crumb_nodes.pop if frontpage_candidate && frontpage_candidate.content_type == 'Section' && frontpage_candidate.content.frontpage_node == crumb_nodes.last

    # move in a suffix, if any
    # Warning: some 'ad-hoc' solutions for supporting subcatergories in opus PDCs. Do _not_ port to treehouse
    suffix = options.delete(suffix) || @category
    if suffix
      product = crumb_nodes.pop if @category && node.content_type == 'Product'
      crumb_nodes += suffix.ancestors.sort_by(&:id)
      crumb_nodes << suffix
      crumb_nodes << product unless product.nil?
    end

    link_options = {}
    link_options[:popup] = true if options[:popup_window]

    if crumb_nodes.size >= options[:minimum_crumbs]
      crumb_nodes.each do |node|
        crumb_track << (crumb_track.blank? ? '' : options[:separator])

        n = nil

        if node.class == Node
          n = node.content
        else
          n = node
        end

        if node != crumb_nodes.last
          if node.class == Node && node.root?
            crumb_track << link_to(html_escape(n.content_title), root_path, {}, link_options)
          elsif node.class == Node
            crumb_track << link_to_content_node(html_escape(n.content_title), n, {}, link_options)
          elsif node.class.name == 'ProductCategory'
            crumb_track << link_to(html_escape(n.title), product_catalogue_products_path(product_catalogue_id: @product_catalogue, selection: 'category', selection_id: n.id))
          end
        elsif node.class == Node
          crumb_track << "<span class='last_crumb'>#{(options[:skip_link_self] ? n.content_title : link_to_content_node(html_escape(n.content_title), n, {}, link_options))}</span>"
        elsif node.class.name == 'ProductCategory'
          crumb_track << "<span class='last_crumb'>#{(options[:skip_link_self] ? n.title : link_to(html_escape(n.title), product_catalogue_products_path(product_catalogue_id: @product_catalogue, selection: 'category', selection_id: n.id)))}</span>"
        end
      end
    end

    crumb_track.html_safe
  end

  # Prints error messages for an AR object in a minimal, side box fitting layout
  # element.
  def side_box_error_messages_for(obj)
    list_items = obj.errors.full_messages.map { |msg| content_tag(:li, msg) }.join("\n").html_safe
    content_tag(:ul, list_items, class: 'errors')
  end

  # Returns the HTML for the footer menu links.
  def create_footer_menu_links
    current_site.children.accessible.public.shown_in_menu.all(order: 'nodes.position ASC').map do |node|
      link_to_node(h(node.content_title.downcase), node)
    end.join(' | ').html_safe
  end

  # Generates include tags for the given scripts and places them in the head
  # element of the page.
  def include_js(*scripts)
    content_for :javascript do
      scripts.map do |script|
        javascript_include_tag(script)
      end.join('').html_safe
    end
  end

  def label_tag_for(name, text = nil, options = {}, &block)
    content_tag(:label, "#{capture(&block)} #{text}".html_safe, options)
  end

  def pink_arrow_button(alt = nil, options = {}, &block)
    content_tag(:div, options.reverse_merge(class: 'go')) { image_tag('arrow_pink.png', class: 'icon', alt: alt) + capture(&block) }
  end

  def blue_arrow_button(alt = nil, options = {}, &block)
    content_tag(:div, options.reverse_merge(class: 'go')) { image_tag('arrow_blue.png', class: 'icon', alt: alt) + capture(&block) }
  end

  def orange_arrow_button(alt = nil, options = {}, &block)
    content_tag(:div, options.reverse_merge(class: 'go')) { image_tag('arrow_orange.png', class: 'icon', alt: alt) + capture(&block) }
  end

  def arrow_block_button(title = nil, options = {}, &block)
    content_tag(:div, options.reverse_merge(class: 'go')) { image_tag('arrow_block.png', class: 'icon transparent', alt: '', title: title) + capture(&block) }
  end

  def news_item_button(title = nil, &block)
    content_tag(:div, class: 'article') { image_tag('icons/news_item.png', class: 'icon', alt: '', title: title) + capture(&block) }
  end

  def edit_button(title = nil, &block)
    content_tag(:div, class: 'edit') { image_tag('icons/pencil.png', class: 'icon', alt: 'Icoon van een wijzigteken', title: title) + capture(&block) }
  end

  def delete_button(title = nil, &block)
    content_tag(:div, class: 'delete') { image_tag('icons/delete.png', class: 'icon', alt: 'Icoon van een verwijderteken', title: title) + capture(&block) }
  end

  def right_new_button(title = nil, &block)
    content_tag(:div, class: 'newRight') { image_tag('icons/add.png', class: 'icon', alt: 'Icoon van een plusteken', title: title) + capture(&block) }
  end

  # Generates a print button.
  def print_button
    content_tag(:div, class: 'print') do
      image_tag('icons/print.png', class: 'icon', alt: '', title: t('application.print_title')) +
      link_to(t('application.print'), '?layout=print', title: t('application.print_title'), rel: 'nofollow')
    end
  end

  def header_image(node = nil, big_header = false)
    random_image = (node || current_site).random_header_image

    if random_image.nil?
      header_title = t('application.default_header_photo_alt')
      image_url    = asset_path('default_header_photo.jpg')
      image_tag    = image_tag(image_url, alt: header_title, title: header_title)
    elsif (big_header)
      header_title = random_image.title
      image_url    = content_node_path(random_image, action: :big_header, format: :jpg)
      image_tag    = image_tag content_node_path(random_image, action: :big_header, format: :jpg), alt: random_image.alt, title: header_title
    else
      header_title = random_image.title
      image_url    = content_node_path(random_image, action: :header, format: :jpg)
      image_tag    = image_tag content_node_path(random_image, action: :header, format: :jpg), alt: random_image.alt, title: header_title
    end

    { title: header_title, image_tag: image_tag, url: image_url }
  end

  def header_slideshow(node, big_header = false, cache_slidehow = true)
    if cache_slidehow
      string_cache(header_slideshow_for: (node.present? ? node.header_container_ancestry : current_site.child_ancestry)) do
        header_slideshow_content node, big_header
      end
    else
      header_slideshow_content node, big_header
    end
  end

  def header_slideshow_content(node, big_header)
    capture do
      available_header_images_nodes = node.present? ? node.header_images : []
      available_header_images_nodes << header_image(node, big_header)[:url] if available_header_images_nodes.empty?

      available_header_images = available_header_images_nodes.map.each_with_index do |header_image, index|
        if header_image.is_a?(String)
          {
            url:   header_image,
            id:    "header-image-#{index}",
            alt:   '',
            title: nil
          }
        else
          {
            url:   big_header ? content_node_path(header_image, action: :big_header, format: :jpg) : content_node_path(header_image, action: :header, format: :jpg),
            id:    "ss-image-#{header_image.id}",
            alt:   header_image.alt.to_s,
            title: (header_image.title if header_image.alt.present?)
          }
        end
      end

      render partial: '/layouts/partials/header_slideshow', locals: { available_header_images: available_header_images }
    end
  end

  def image_url(source)
    abs_path = compute_public_path(source, 'images')
    unless abs_path =~ /\Ahttp/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
    abs_path
  end

  def social_media_buttons(page)
    social_media_button(page, 'social_twitter.png',  t('application.add_to_twitter'),  'http://twitter.com/?status={{title}}%20{{url}}') +
    social_media_button(page, 'social_facebook.png', t('application.add_to_facebook'), 'http://www.facebook.com/sharer.php?u={{url}}&amp;t={{title}}') +
    social_media_button(page, 'social_blogger.png',  t('application.add_to_blogger'),  'http://www.blogger.com/blog_this.pyra?t=&amp;u={{url}}&amp;n={{title}}') +
    email_button(page, 'email.png', t('application.email_page'))
  end

  def social_media_button(object, image, alt, url)
    url = url.gsub(/\{\{url\}\}/, u("http://#{request.host}/#{object.node.url_alias}")).gsub(/\{\{title\}\}/, u(object.title))
    link_to(image_tag("icons/#{image}", alt: alt, title: alt, class: 'icon'), url, rel: 'nofollow')
  end

  def social_media_link(image, alt, url)
    link_to(image_tag("icons/#{image}", alt: alt, title: alt, class: 'icon'), url, rel: 'nofollow')
  end

  def email_button(object, image, alt)
    link_to(image_tag("icons/#{image}", alt: alt, title: alt, class: 'icon'), new_share_path(node_id: @node.id), rel: 'nofollow')
  end

  def read_more_link(content, text = t('shared.read_more'), options = {})
    options.reverse_merge! title: "#{t('shared.read_more')} uit #{content.title}"
    link_to_content_node text, content, {}, class: 'read_more_link', title: options[:title]
  end

  def new_button(title = nil, &block)
    concat(content_tag(:div, class: 'new') { image_tag('icons/add.png', class: 'icon', alt: 'Icoon van een plusteken', title: title) + capture(&block) })
  end

  def string_cache(name = {}, options = nil, &block)
    if controller.perform_caching
      if fragment = controller.read_fragment(name, options)
        fragment.html_safe
      else
        controller.write_fragment(name, yield.to_s, options).html_safe
      end
    else
      yield
    end
  end

  def skippable(id, &block)
    # Add random number to prevent duplicate ids
    id = "#{id}-#{SecureRandom.random_number(1000)}"
    link_to(t('shared.skip_to_bottom'), "\#bottom_of_#{id}", id: "top_of_#{id}", class: 'text-alternative') +
    capture(&block) +
    link_to(t('shared.skip_to_top'),    "\#top_of_#{id}", id: "bottom_of_#{id}", class: 'text-alternative')
  end

  def target_contrast_mode
    @high_contrast_mode ? :low : :high
  end

  def contrast_mode_text
    t(target_contrast_mode, scope: [:shared, :contrast])
  end

  def switch_contrast_mode_link(show_text = false)
    if show_text
      link_text = image_tag('icons/contrast-high-icon.png', class: 'icon', alt: '') + contrast_mode_text
    else
      link_text = image_tag('icons/contrast-high-icon.png', class: 'icon', alt: contrast_mode_text, title: contrast_mode_text)
    end

    link_to link_text, params.merge(contrast: target_contrast_mode), rel: 'nofollow'
  end

  protected

  def render_images
    return if @image_content_nodes.blank?

    render(partial: 'shared/images_bar', locals: { images: @image_content_nodes, rel: @node.id })
  end

  def render_attachments
    render(partial: 'shared/attachments', locals: { container: @node.content, attachments: @attachment_nodes, rel: @node.id }) if @attachment_nodes.present? || (@node && @node.children.accessible.with_content_type(%w(AttachmentTheme)).count > 0)
  end

  # Override +error_messages_for+ to override default header message. For some
  # reason the localization plugin doesn't allow us to override it manually.
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys

    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.map { |object_name| instance_variable_get("@#{object_name}") }.compact
    end

    count = objects.inject(0) { |sum, object| sum + object.errors.count }

    if count.zero?
      ''
    else
      html = {}

      [:id, :class].each do |key|
        if options.include?(key)
          value     = options[key]
          html[key] = value if value.present?
        else
          html[key] = 'errorExplanation'
        end
      end

      options[:object_name] ||= params.first
      options[:header_message] = t('application.save_error') unless options.include?(:header_message)
      options[:message] ||= (count > 1) ? t('application.field_errors') : t('application.field_error') unless options.include?(:message)
      error_messages = objects.map { |object| object.errors.full_messages.map { |msg| content_tag(:li, msg) } }

      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) if options[:header_message].present?
      contents << content_tag(:p, options[:message]) if options[:message].present?
      contents << content_tag(:ul, error_messages.join("\n").html_safe)

      content_tag(:div, contents.html_safe, html)
    end
  end
end
