module Admin::AdminFormBuilderHelper

  [:form_for, :fields_for].each do |fh|
    module_eval <<-RB
      def admin_#{fh}(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.update(:builder => Admin::AdminFormBuilder)
        args = (args << options)
        send(:#{fh}, name, *args, &block)
      end
    RB
  end

  [ :form_remote_for, :remote_form_for ].each do |fh|
    module_eval <<-RB
      def admin_#{fh}(name, *args, &block)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.update(:builder => Admin::AdminFormBuilder)
        options.update(:after => 'this.disable()')

        options.update(:before => 'resetTinyMCE()')
        options.update(:failure => "Ext.ux.alertResponseError(request)")

        args = (args << options)
        send(:#{fh}, name, *args, &block)
      end
    RB
  end

  def admin_form_remote_tag(*args, &block)
    options = args.last.is_a?(Hash) ? args.pop : {}
    options.update(:builder => Admin::AdminFormBuilder)
    options.update(:after   => 'this.disable()')

    options.update(:before  => 'resetTinyMCE()')
    options.update(:failure => "Ext.ux.alertResponseError(request)")

    args = (args << options)
    send(:form_remote_tag, *args, &block)
  end

  def wrap_with_label(field, label, options_for_wrapper = {})
    reverse    = label[:for_check_box] || false
    label_html = content_tag(:label, label[:text], :for => label[:for])
    if !reverse
      content_tag(:div, (label_html + field), { :class => 'formFieldCt clearfix' }.merge(options_for_wrapper))
    else 
      content_tag(:div, (field + label_html), { :class => 'formFieldCb clearfix' }.merge(options_for_wrapper))
    end
  end

  def admin_submit_tag(*args)
    content_tag(:div, submit_tag(*args), :class => "adminSubmitBtn")
  end

  def admin_date_field_tag(name, value = nil, options = {})
    id      = options[:id] || name_to_id(name)
    html    = content_tag(:div, String.new, :id => "#{id}_ct")
    value ||= Time.now unless options[:allow_empty] # default to current date
    value   = value.strftime("%d-%m-%Y") unless value.nil? # format for Ext component
    js = javascript_tag <<-JS
      new Ext.form.DateField({
          id: '#{id}',
          name: '#{name}',
          format: 'd-m-Y',
          width: #{options[:width] || 250},
          value: '#{value}',
          renderTo: '#{id}_ct'
      });
    JS
    (html + js)
  end

  def admin_time_field_tag(name, value = nil, options = {})
    id      = options[:id] || name_to_id(name)
    html    = content_tag(:div, String.new, :id => "#{id}_ct")
    value ||= Time.now unless options[:allow_empty] # default to current date
    value   = value.strftime("%H:%M") unless value.nil? # format for Ext component
    js = javascript_tag <<-JS
      new Ext.form.TimeField({
          id: '#{id}',
          name: '#{name}',
          format: 'H:i',
          width: #{options[:width] || 250},
          value: '#{value}',
          renderTo: '#{id}_ct'
      });
    JS
    (html + js)
  end

  protected

  def name_to_id(name)
    name.to_s.gsub(/\]\z/, '').gsub(/\[\]/, '').gsub(/[\[\]]/, '_')
  end
end
