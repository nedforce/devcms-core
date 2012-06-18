module WhiteListHelper
  
  def white_list html, configuration = nil
    Sanitize.clean(tidy_html(html.to_s), configuration || Sanitize::Config::CUSTOM).html_safe
  end
  
  alias_method :w, :white_list
  
end