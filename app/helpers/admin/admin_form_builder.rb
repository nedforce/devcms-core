class Admin::AdminFormBuilder < ActionView::Helpers::FormBuilder
  (field_helpers - ['hidden_field']).each do |fh|
    define_method(fh) do |attr, *args|
      options           = args.last.is_a?(Hash) ? args.pop : {}
      options[:class] ||= "admin_form_#{fh.to_s}"
      args              = (args << options)
      id, name          = id_and_name(attr)
      for_check_box     = options.delete(:for_check_box)
      wrapper           = options.delete(:wrapper) || {}
      if options[:label] === false
        super(attr, *args)
      else
        @template.wrap_with_label(
          super(attr, *args),
          { :text          => (options[:label] || @object.class.human_attribute_name(attr)),
            :for           => "#{@object_name}_#{attr}",
            :for_check_box => for_check_box },
          { :id => "#{id}_wrapper" }.merge(wrapper)
        )
      end
    end
  end

  def html_editor(attr, options = {})
    id, name = id_and_name(attr)
    html     = @template.html_editor_tag(name, @object.send(attr), {:id => id}.merge(options))
    html     = @template.content_tag(:div, html, :class => 'fieldWithErrors') if @object.errors[attr].any?
    @template.wrap_with_label(html, { :text => (options[:label] || attr.to_s.humanize), :for => id }, { :id => "#{id}_wrapper" }.merge(options.delete(:wrapper)||{}))
  end

  def select_field(attr, values, options = {}, html_options = {})
    id, name = id_and_name(attr)
    html     = @template.select(@object_name, attr, values, {:id => id}.merge(options), html_options)
    html     = @template.content_tag(:div, html, :class => 'fieldWithErrors') if @object.errors[attr].any?
    @template.wrap_with_label(html, { :text => (options[:label] || attr.to_s.humanize), :for => id }, { :id => "#{id}_wrapper" }.merge(options.delete(:wrapper)||{}))
  end

  def select_tag_field(attr, values, options = {})
    id, name = id_and_name(attr)
    label    = options.delete(:label)
    html     = @template.select_tag(attr, values, { :id => id }.merge(options))
    html     = @template.content_tag(:div, html, :class => 'fieldWithErrors') if @object.errors[attr].any?
    @template.wrap_with_label(html, { :text => label, :for => id }, { :id => "#{id}_wrapper" }.merge(options.delete(:wrapper)||{}))
  end
  
  def submit(*args)
    @template.admin_submit_tag(*args)
  end

  def date_field(attr, options = {})
    id, name    = id_and_name(attr)
    val         = options[:value]||@object.read_attribute(attr)
    allow_empty = options.delete(:allow_empty)
    disabled    = options.delete(:disabled)
    @template.wrap_with_label(@template.admin_date_field_tag(name, val, :id => id, :allow_empty => allow_empty, :disable => disabled), { :text => options[:label] || attr.to_s.humanize, :for => id }, { :id => "#{id}_wrapper" }.merge(options[:wrapper]||{}))
  end

  def time_field(attr, options = {})
    id, name    = id_and_name(attr)
    val         = options[:value]||@object.read_attribute(attr)
    allow_empty = options.delete(:allow_empty)
    @template.wrap_with_label(@template.admin_time_field_tag(name, val, :id => id, :allow_empty => allow_empty), { :text => options[:label] || attr.to_s.humanize, :for => id }, { :id => "#{id}_wrapper" }.merge(options[:wrapper]||{}))
  end

  def help_text(txt)
    @template.content_tag(:div, txt, :class => 'formFieldCt helpText')
  end
  
  def node_selector(attr, options = {})
    id, name    = id_and_name(attr)
    val         = options[:value] || @object.read_attribute(attr)
    label       = options[:label] || @object.class.human_attribute_name(attr)
    label       += "<br/><small>#{I18n.t "#{@object.class.name.tableize}.drag_and_drop"}</small>" unless options[:label] || options[:hint] == false
    node        = @object.send(attr.to_s.gsub('_id', ''))

    html = [@template.wrap_with_label(@template.content_tag(:div, '', :id => "#{id}_node_selector"), { :text => label.html_safe, :for => id }, { :id => "#{id}_wrapper" }.merge(options.delete(:wrapper)||{}))]
    html << @template.javascript_tag do
      <<-EOS.html_safe
      new Ext.dvtr.NodeDropField({
        renderTo: '#{id}_node_selector',
        ddGroup: 'TreeAndSorterDD',
        name: '#{@object.class.name.underscore}[#{attr}]',
        id: '#{id}',
        value: '#{val}',
        text: '#{node.try(:title)}',
        width: 60
      });
      EOS
    end

    html.join("\n").html_safe
  end

  protected

  def id_and_name(attr)
    ["#{@object_name}_#{attr}", "#{@object_name}[#{attr}]"]
  end
end
