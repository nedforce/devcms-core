module ApplicationHelper

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
      content_tag(:div, :class => "flash #{key}") do
        content_tag(:p, image_tag("icons/#{key}.png", :class => 'icon', :alt => key) + flash[key].to_s)
      end
    end.join
  end

  # Creates the breadcrumbs element, which displays links to all the node's ancestors.
  #
  # See documentation of +bread_crumbs_track_for+ for more information.
  def bread_crumbs_for(node, options = {})
    crumb_track = bread_crumbs_track_for(node, options)

    content_tag(:div, crumb_track, :class => 'bread_crumbs') if crumb_track.present?
  end

  # Creates the breadcrumbs element, which displays links to all the node's ancestors.
  #
  # *arguments*
  # +node+ - The node for which breadcrumbs should be created. It will add all ancestors to it
  # +options+ A hash with breadcrumb and link options:
  # :include_root: Include the root node in the path
  # :minimum_crumbs: The number of crumbs that should be in the path
  # :separator: The seperator between two crumbs
  # :popup_window: Link option: when clicked on a crumb, it will open in a new window (using javascript)
  # :skip_link_self: Link option: Don't create a link for +node+. Useful when a node is invisible or unapproved
  # :suffix: A tree that follows the node, e.g. a category of a product catalogue
  def bread_crumbs_track_for(node, options = {})
    options = { :minimum_crumbs => 1, :separator => ' &gt; ', :include_root => true }.merge(options)

    host = options.delete :host

    crumb_track = String.new
    crumb_nodes = node.self_and_ancestors
    crumb_nodes.shift unless node.containing_site.root?
    crumb_nodes.shift unless options[:include_root]
    # Remove frontpage node to prevent semingly double crumbs
    frontpage_candidate = crumb_nodes[-2]
    crumb_nodes.pop if frontpage_candidate && frontpage_candidate.content_type == "Section" && frontpage_candidate.content.frontpage_node == crumb_nodes.last
    
    # move in a suffix, if any
    # Warning: some 'ad-hoc' solutions for supporting subcatergories in opus PDCs. Do _not_ port to treehouse
    suffix = options.delete(suffix) || @category
    if suffix
      product = crumb_nodes.pop if @category && node.content_type == 'Product'
      crumb_nodes += suffix.ancestors.sort_by { |s| s.id }
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
            crumb_track << link_to(html_escape(n.title), product_catalogue_products_path(:product_catalogue_id => @product_catalogue, :selection => 'category', :selection_id => n.id))
          end
        elsif node.class == Node
          crumb_track << "<span class='last_crumb'>#{(options[:skip_link_self] ? n.content_title : link_to_content_node(html_escape(n.content_title), n, {}, link_options))}</span>"
        elsif node.class.name == 'ProductCategory'
          crumb_track << "<span class='last_crumb'>#{(options[:skip_link_self] ? n.title : link_to(html_escape(n.title), product_catalogue_products_path(:product_catalogue_id => @product_catalogue, :selection => 'category', :selection_id => n.id)))}</span>"
        end
      end
    end

    crumb_track
  end

  # Prints error messages for an AR object in a minimal, side box fitting layout element.
  def side_box_error_messages_for(obj)
    list_items = obj.errors.full_messages.map{ |msg| content_tag(:li, msg) }.join("\n")
    content_tag(:ul, list_items, :class => 'errors')
  end

  # Returns the html for the double-level main menu.
  def create_main_menu
    top_level_main_menu_items = current_site.closure_for(current_site.descendants(:to_depth => 2).accessible.public.shown_in_menu.all(:order => :position)).values.first

    if top_level_main_menu_items.any?
      content_tag(:ul, top_level_main_menu_items.map { |item, sub_items| create_main_menu_item(item, sub_items.keys) }.join("\n"), :id => 'main_menu', :class => 'clearfix')
    else
      '&nbsp;' # No menu if no top level main menu items
    end
  end

  # Returns the HTML for the multi-level sub menu.
  def create_sub_menu(self_and_ancestor_ids, top_sub_menu_items, show_private_items_in_sub_menu)
    sub_menu_content = top_sub_menu_items.map do |item|
      create_sub_menu_item(item, self_and_ancestor_ids[1..-1], show_private_items_in_sub_menu, :class => 'top_level')
    end.join("\n")

    content_tag(:ul, sub_menu_content, :id => 'sub_menu')
  end

  # Returns the HTML for the footer menu links.
  def create_footer_menu_links
    current_site.children.accessible.public.shown_in_menu.all(:order => 'nodes.position ASC').map do |node|
      link_to_node(h(node.content_title.downcase), node)
    end.join(' | ')
  end

  # Generates include tags for the given scripts and places them in the head element of the page.
  def include_js(*scripts)
    content_for :javascript do
      scripts.map do |script|
        javascript_include_tag(script, :plugin => 'devcms-core')
      end.join('')
    end
  end

  def label_tag_for(name, text = nil, options = {}, &block)
    content_tag(:label, "#{yield} #{text}", options)
  end

  def pink_arrow_button(alt = nil, options = {}, &block)
    concat(content_tag(:div, options.reverse_merge(:class => 'go')) { image_tag('arrow_pink.png', :class => 'icon', :alt => alt) + capture(&block) })
  end

  def blue_arrow_button(alt = nil, options = {}, &block)
    concat(content_tag(:div, options.reverse_merge(:class => 'go')) { image_tag('arrow_blue.png', :class => 'icon', :alt => alt) + capture(&block) })
  end

  def orange_arrow_button(alt = nil, options = {}, &block)
    concat(content_tag(:div, options.reverse_merge(:class => 'go')) { image_tag('arrow_orange.png', :class => 'icon', :alt => alt) + capture(&block) })
  end

  def arrow_block_button(title = nil, options = {}, &block)
    concat(content_tag(:div, options.reverse_merge(:class => 'go')) { image_tag('arrow_block.png', :class => 'icon transparent', :alt => 'Icoon van een pijl', :title => title) + capture(&block) })
  end

  def news_item_button(title = nil, &block)
    concat(content_tag(:div, :class => 'article') { image_tag('icons/news_item.png', :class => 'icon', :alt => 'Icoon van een artikel', :title => title) + capture(&block) })
  end

  def edit_button(title = nil, &block)
    concat(content_tag(:div, :class => 'edit') { image_tag('icons/pencil.png', :class => 'icon', :alt => 'Icoon van een wijzigteken', :title => title) + capture(&block) })
  end

  def delete_button(title = nil, &block)
    concat(content_tag(:div, :class => 'delete') { image_tag('icons/delete.png', :class => 'icon', :alt => 'Icoon van een verwijderteken', :title => title) + capture(&block) })
  end

  def right_new_button(title = nil, &block)
    concat(content_tag(:div, :class => 'newRight') { image_tag('icons/add.png', :class => 'icon', :alt => 'Icoon van een plusteken', :title => title) + capture(&block) })
  end

  # Generates a print button.
  def print_button
    content_tag(:div, :class => 'print') do
      image_tag('icons/print.png', :class => 'icon', :alt => '', :title => t('application.print_title')) +
      link_to(t('application.print'), "?layout=print", :title => t('application.print_title'), :rel => 'nofollow')
    end
  end

  # Generates a button/link for readspeaker. A readspeaker id needs to be specified if multiple readspeak buttons are used on a page.
  def readspeaker_button(options = {})
    if Settler[:readspeaker_cid].present?
      rid = options.delete(:rid)
      link_class = [ options.delete(:class), 'readspeaker_link' ].compact.join(' ')
      readspeaker_url = readspeaker_url_for(request.url, { :rid => rid }.merge(options))

      content_tag(:div, :class => 'readspeaker_button') do
        (image_tag('icons/sayit.png', :class => 'icon', :alt => t('application.sayit_alt'), :title => t('application.sayit_title')) +
        (link_to(t('application.sayit'), readspeaker_url, { :class => link_class }.merge(options))) unless @node && (@node.hidden? || @node.private? || !@node.publishable?))
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

    readspeaker_block = rid.blank? ? html : content_tag(:div, html, :id => "readspeaker_block_#{rid}")
    block_called_from_erb?(block) ? concat(readspeaker_block) : readspeaker_block
  end

  # Returns a url to readspeaker.
  def readspeaker_url_for(target_url, options = {})
    url  = "http://app.readspeaker.com/cgi-bin/rsent?customerid=#{Settler[:readspeaker_cid]}"
    url << "&amp;readid=readspeaker_block_#{options[:rid]}" unless options[:rid].blank?
    url << "&amp;lang=#{options[:lang] || 'nl'}"
    url << "&amp;url=#{CGI.escape(target_url)}"
    url
  end

  # Return pagination info and links.
  def pagination_links(paginator)
    links  = []
    links << link_to(t('application.previous_page'), params.merge({ :page => paginator.previous_page }), { :class => 'left'  }) if paginator.previous_page?
    links << link_to(t('application.next_page'),     params.merge({ :page => paginator.next_page     }), { :class => 'right' }) if paginator.next_page?
    links << paginating_links(paginator, :params => params, :window_size => 10)
    content_tag(:div, :class => 'pagination clearfix') do
      links.join
    end
  end

  # Returns a string whose HTML format and structure has been cleaned.
  #
  # *Parameters*
  #
  # +str+ - String to clean.
  def tidy_html(str)
    RailsTidy.tidy_factory.clean(str)
  end

  def white_list_preamble(str)
    white_list(str, :tags => ['span'], :attributes => ['lang', 'xml:lang'], :override_defaults => true)
  end

  def header_image(node = nil, big_header = false)
    random_image = (node || current_site).random_header_image

    if random_image.nil?
      header_title = t('application.default_header_photo_alt')
      image_url    = '/images/default_header_photo.jpg'
      image_tag    = image_tag(image_url, :alt => header_title, :title => header_title)
    elsif (big_header)
      header_title = random_image.title
      image_url    = big_header_image_path(random_image, :format => :jpg)
      image_tag    = image_tag big_header_image_path(random_image, :format => :jpg), :alt => random_image.alt, :title => header_title
    else
      header_title = random_image.title
      image_url    = header_image_path(random_image, :format => :jpg)
      image_tag    = image_tag header_image_path(random_image, :format => :jpg), :alt => random_image.alt, :title => header_title
    end

    return { :title => header_title, :image_tag => image_tag, :url => image_url }
  end

  def header_slideshow(node, big_header = false)
    available_header_images_nodes = node.present? ? node.header_images : []
    available_header_images_nodes << header_image(node, big_header)[:url] if available_header_images_nodes.empty?
    
    available_header_images = available_header_images_nodes.map do |header_image|
      if header_image.is_a?(String)
        {
          :url   => header_image,
          :id    => nil,
          :alt   => nil,
          :title => nil
        }
      else
        {
          :url   => big_header ? big_header_image_path(header_image, :format => :jpg) : header_image_path(header_image, :format => :jpg),
          :id    => "ss-image-#{header_image.id}",
          :alt   => header_image.alt,
          :title => header_image.title
        }
      end
    end
    
    render :partial => '/layouts/partials/header_slideshow', :locals => { :available_header_images => available_header_images }
  end

  def image_url(source)
    abs_path = compute_public_path(source, 'images')
    unless abs_path =~ /^http/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
   abs_path
  end  

  def social_media_buttons(page)
    social_media_button(page, 'social_twitter.png',  t('application.add_to_twitter'),  'http://twitter.com/?status={{title}}%20{{url}}') +
    social_media_button(page, 'social_facebook.png', t('application.add_to_facebook'), 'http://www.facebook.com/sharer.php?u={{url}}&amp;t={{title}}') +
    social_media_button(page, 'social_linkedin.png', t('application.add_to_linkedin'), 'http://www.linkedin.com/shareArticle?mini=true&amp;url={{url}}&amp;title={{title}}&amp;source={{title}}') +
    social_media_button(page, 'social_blogger.png',  t('application.add_to_blogger'),  'http://www.blogger.com/blog_this.pyra?t=&amp;u={{url}}&amp;n={{title}}') +
    email_button(page, 'email.png', t('application.email_page'))
  end

  def social_media_button(object, image, alt, url)
    url = url.gsub(/\{\{url\}\}/, u("http://#{request.host}/#{object.node.url_alias}")).gsub(/\{\{title\}\}/, u(object.title))
    link_to(image_tag("/images/icons/#{image}", :alt => alt, :title => alt, :class => 'icon'), url)
  end

  def social_media_link(image, alt, url)
    link_to(image_tag("/images/icons/#{image}", :alt => alt, :title => alt, :class => 'icon'), url)
  end

  def email_button(object, image, alt)
    link_to(image_tag("/images/icons/#{image}", :alt => alt, :title => alt, :class => 'icon'), new_share_path(:node_id => @node.id))
  end

  def read_more_link(content, text = t('shared.read_more'))
    link_to_content_node text, content, {}, :class => 'read_more_link'
  end

  def new_button(title = nil, &block)
    concat(content_tag(:div, :class => 'new') { image_tag('icons/add.png', :class => 'icon', :alt => 'Icoon van een plusteken', :title => title) + capture(&block) })
  end

  protected

    # Returns the HTML for a main menu item.
    #
    # *arguments*
    # +node+ - The node to create a main menu item for.
    def create_main_menu_item(node, children)
      #active = (@node && @node.path_ids.include?(node.id)) ? 'active' : ''

      if children.empty?
        content_tag(:li, create_menu_link(node, :class => 'main_menu_link'), :class => "#{node.own_or_inherited_layout_configuration['template_color']}")
      else
        link             = create_menu_link(node, :class => 'main_menu_link')
        sub_menu_items   = children.map { |child| content_tag(:li, create_menu_link(child, :class => 'sub_menu_link')) }
        sub_menu         = content_tag(:ul,  sub_menu_items, :class => 'sub_menu')
        sub_menu_wrapper = content_tag(:div, sub_menu,       :class => 'sub_menu_wrapper')
        content_tag(:li, link + sub_menu_wrapper, :class => "#{node.own_or_inherited_layout_configuration['template_color']} hover")
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
          sub_menu_items = node.children.accessible.shown_in_menu.all(:order => 'position')
        else
          sub_menu_items = node.children.accessible.shown_in_menu.all(:order => 'position').select do |sub_menu_item|
            sub_menu_item.public? || current_user_has_any_role?(sub_menu_item) 
          end
        end
      else
        sub_menu_items = node.children.accessible.public.shown_in_menu.all(:order => 'position')
      end
      
      has_sub_menu_items = sub_menu_items.any?

      options[:class] = options[:class] ? "#{options[:class]} parent" : "parent" if has_sub_menu_items

      unless self_and_ancestors_except_root_ids.include?(node.id)
        content_tag(:li, create_menu_link(node, :class => 'sub_menu_link'), options)
      else
        classes = %w( sub_menu_link expanded )
        classes << 'current' if node == @node || (node.content.is_a?(Section) && node.content.frontpage_node_id == @node.id)
        
        content = create_menu_link(node, :class => classes.join(' '))

        if has_sub_menu_items
          content += content_tag(:ul, sub_menu_items.map { |item| create_sub_menu_item(item, self_and_ancestors_except_root_ids, show_private_items_in_sub_menu) }.join("\n"))
        end

        options[:class] = options[:class] ? "#{options[:class]} expanded" : "expanded" 

        content_tag(:li, content, options)
      end
    end

    def create_menu_link(node, opts = {})
      link_to_node(h(node.content_title), node, {}, { :title => h(node.content_title) }.merge(opts))
    end

    def render_images
      render(:partial => 'shared/images_bar', :locals => { :images => @image_content_nodes, :rel => @node.id }) unless @image_content_nodes.blank?
    end

    def render_attachments
      render(:partial => 'shared/attachments', :locals => { :container => @node.content, :attachments => @attachment_nodes, :rel => @node.id }) if @attachment_nodes.present? || (@node && @node.children.accessible.with_content_type(%w(AttachmentTheme)).count > 0)
    end

    # Override +error_messages_for+ to override default header message. For some reason the localization
    # plugin doesn't allow us to override it manually.
    def error_messages_for(*params)
      options = params.extract_options!.symbolize_keys

      if object = options.delete(:object)
        objects = [object].flatten
      else
        objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
      end

      count = objects.inject(0) {|sum, object| sum + object.errors.count }

      unless count.zero?
        html = {}

        [:id, :class].each do |key|
          if options.include?(key)
            value     = options[key]
            html[key] = value if value.present?
          else
            html[key] = 'errorExplanation'
          end
        end

        options[:object_name]  ||= params.first
        options[:header_message] = t('application.save_error') unless options.include?(:header_message)
        options[:message]      ||= (count > 1) ? t('application.field_errors') : t('application.field_error') unless options.include?(:message)
        error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }

        contents = ''
        contents << content_tag(options[:header_tag] || :h2, options[:header_message]) if options[:header_message].present?
        contents << content_tag(:p, options[:message]) if options[:message].present?
        contents << content_tag(:ul, error_messages)

        content_tag(:div, contents, html)
      else
        ''
      end
    end
end
