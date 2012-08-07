module WhiteListHelper
  # Returns a string whose HTML format and structure has been cleaned.
  #
  # *Parameters*
  #
  # +str+ - String to clean.
  def tidy_html(str)
    TidyFFI::Tidy.clean(str, :show_body_only => 1, :output_xhtml => 1, :input_encoding => 'utf8', :wrap => 0)
  end

  def white_list_preamble(str)
    white_list(str, :elements => ['span'], :attributes => { 'span' => ['lang', 'xml:lang'] })
  end
  
  def white_list html, configuration = nil
    tidy_html(Sanitize.clean(html.to_s, configuration || Sanitize::Config::CUSTOM)).html_safe
  end
  
  alias_method :w, :white_list
  
end