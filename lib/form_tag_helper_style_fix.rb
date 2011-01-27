module FormTagHelperStyleFix
  private

  def extra_tags_for_form(html_options)
    case method = html_options.delete("method").to_s
      when /\Aget\z/i # must be case-insentive, but can't use downcase as might be nil
        html_options["method"] = "get"
        ''
      when /\Apost\z/i, "", nil
        html_options["method"] = "post"
        protect_against_forgery? ? content_tag(:div, token_tag, :class => 'authenticity_token') : ''
      else
        html_options["method"] = "post"
        content_tag(:div, tag(:input, :type => "hidden", :name => "_method", :value => method) + token_tag, :class => 'authenticity_token')
    end
  end
end
