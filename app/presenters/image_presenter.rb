class ImagePresenter < BasePresenter
  def content_box_title;  @object.content_box_title.to_s     end
  def content_box_title?; @object.content_box_title.present? end
  def description;        @object.description.to_s           end
  def alt;                @object.alt.to_s                   end
  def url;                @object.url                        end
  def url?;               @object.url.present?               end

  def image(options = {})
    if description.present?
      h.link_to image_tag(options), url, title: description
    else
      h.link_to image_tag(options), url
    end
  end

  def lightbox_image(node = nil)
    h.link_to_node [image_tag, hidden_title].join.html_safe, (node || @object.node), { action: :full }, { data: { lightbox: "lightbox['sidebox']" }, title: 'Vergroot deze afbeelding' }
  end

  def image_tag(options = {})
    options[:action] = options.delete(:action) || :banner
    options[:format] = options.delete(:format) || 'jpg'

    h.content_tag :div, class: 'image-wrapper' do
      [ h.image_tag(h.content_node_path(@object, options), alt: alt),
        (content_box_title? ? h.content_tag(:div, content_box_title, class: 'image-overlay-title') : nil)
      ].compact.join.html_safe
    end
  end

  def hidden_title
    h.content_tag :div, description, class: 'hidden'
  end
end
