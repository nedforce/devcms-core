module HtmlEditorHelper

  # Builds HTML for an TinyMCE HTML editor component.
  #
  # <b>Arguments:</b>
  #
  #  * +name+ - Name of the input DOM element as a String.
  #  * +value+ - Initial value of the HtmlEditor component as a String. (Optional).
  #  * +options+ - Render options as a Hash, possible options are: +rows+ (Integer), +cols+ (Integer), +insert_video+ (Boolean) +front_end+ (Boolean).
  def html_editor_tag(name, value = nil, options = {})
    field_id  = options.delete(:id) || name_to_id(name)
    editor_js = init_tinymce_js(value, field_id, options)
    html      = tinymce_html(name, field_id, options)
    html     += javascript_tag(editor_js)
    html
  end

  def tinymce_html(name, field_id, options = {})
    text_area_options = {
      :id    => field_id,
      :class => field_id,
      :rows  => options.delete(:rows) || 16,
      :cols  => options.delete(:cols) || 50
    }

    content_tag(:div,
      content_tag(:div,
        text_area_tag(name, '', text_area_options),
        :id    => "#{field_id}_ct",
        :class => 'tiny_left'
      ),
      :class => 'clearfix'
    )
  end

  def init_tinymce_js(value, field_id, options = {})
    front_end = false || options.delete(:front_end)
    heading   = options.delete(:heading) || "h2"
    width     = options.delete(:width)   || (front_end ? '410' : '600')

    <<-JS
        tinyMCE.init({
          width : "#{width}",
          mode : "textareas",
          theme : "advanced",
          skin : "o2k7",
          verify_html : true,
          plugins: "heading,xhtmlxtras,inlinepopups",
          remove_linebreaks : true,
          remove_trailing_nbsp : true,
          relative_urls : false,
          remove_script_host : false,
          valid_elements : "strong,strong/b,em,em/i,p[lang|xml::lang],code,pre,tt,sub,sup,br,ul,ol,li,abbr[lang|xml::lang],acronym[lang|'xml:lang'],a[href|title],img[src|alt|width|height],blockquote,span[lang|xml::lang],h2,h3,abbr[title]",
          language : "#{I18n.locale}",
          editor_selector : "#{field_id}",
          theme_advanced_toolbar_location : "top",
          theme_advanced_toolbar_align : "left",
          theme_advanced_buttons1 : "bold,italic,separator,#{heading},abbr,separator,strikethrough,bullist,numlist,link,add_video_button#{",code" if logged_in? && current_user.has_role?("admin", "final_editor")}",
          theme_advanced_buttons2 : "",
          theme_advanced_buttons3 : "",
          setup : function(ed) {
            ed.onInit.add(function(ed) {
                ed.setContent('#{escape_javascript(value)}');
            });
            #{insert_video_button unless options.delete(:skip_insert_video)}
          }
        });
        var site_node_id = "#{@node.present? ? @node.containing_site.id : (@parent_node.present? ? @parent_node.containing_site.id : Node.root.id)}";
    JS
  end

private

  def insert_video_button
    "ed.addButton('add_video_button', {
      title : 'Video invoegen',
      image : '/images/icons/film_add.png',
      onclick : function() {
        id = window.prompt('#{escape_javascript(t('video.insert_video'))}', '#{escape_javascript(t('video.enter_video_id'))}')
        if (id) {
          ed.selection.setContent('[[youtube:'+ id +']]');
        }
      }
    });"
  end
end
