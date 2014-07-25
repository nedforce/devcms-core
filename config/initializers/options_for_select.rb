module ActionView
  module Helpers
    module FormOptionsHelper

      def option_html_attributes(element)
        return "" unless Array === element
        html_attributes = []
        element.select { |e| Hash === e }.inject({}) { |m, v| m.merge(v) }.each do |k, v|
          html_attributes << " #{k}=\"#{html_escape(v.to_s)}\""
        end
        html_attributes.join.html_safe
      end

      def option_text_and_value(option)
        # Options are [text, value] pairs or strings used for both.
        if !option.is_a?(String) and option.respond_to?(:first) and option.respond_to?(:second)
          [option.first, option.second]
        else
          [option, option]
        end
      end

      def options_for_select(container, selected = nil)
        return container if String === container

        container = container.to_a if Hash === container
        selected, disabled = extract_selected_and_disabled(selected)

        options_for_select = container.inject([]) do |options, element|
          html_attributes = option_html_attributes(element)
          text, value = option_text_and_value(element)
          selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
          disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
          options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{disabled_attribute}#{html_attributes}>#{html_escape(text.to_s)}</option>)
        end

        options_for_select.join("\n").html_safe
      end
    end
  end
end
