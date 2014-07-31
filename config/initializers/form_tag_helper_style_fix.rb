require 'action_view/helpers/form_tag_helper'

module ActionView::Helpers::FormTagHelper
  private

  def extra_tags_for_form(html_options)
    authenticity_token = html_options.delete('authenticity_token')
    method = html_options.delete('method').to_s

    method_tag = case method
    when /^get$/i # must be case-insensitive, but can't use downcase as might be nil
      html_options['method'] = 'get'
      ''
    when /^post$/i, '', nil
      html_options['method'] = 'post'
      token_tag(authenticity_token)
    else
      html_options['method'] = 'post'
      tag(:input, :type => 'hidden', :name => '_method', :value => method) + token_tag(authenticity_token)
    end

    tags = utf8_enforcer_tag << method_tag
    content_tag(:div, tags, :class => 'authenticity_token')
  end
end
