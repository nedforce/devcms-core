module WhiteListHelper
  
  def white_list html, configuration = nil
    Sanitize.clean(html.to_s, configuration || Sanitize::Config::CUSTOM).html_safe
  end
  
  alias_method :w, :white_list
  
end