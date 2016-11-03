class GoogleSearchResult < GoogleSiteSearch::Result
  include ActionView::Helpers::SanitizeHelper

  def initialize(node)
    @node = node
    super(node)
    @labels = node.find("Label").map(&:content)
  end

  def title
    if (title = promotion_title || super)
      strip_title(title)
    end
  end

  def description
    if (description = promotion_description || super)
      strip_description(description)
    end
  end

  def labels
    @labels
  end

  def promotion_title
    if (title = @node.find("SL_RESULTS/SL_MAIN/T")).any?
      title[0].content
    end
  end

  def promotion_description
    if (promotions = @node.find("SL_RESULTS/SL_MAIN/BODY_LINE/BLOCK/T")).any?
      promotions[0].content
    end
  end

  private

  def strip_html(string, allowed_tags = [])
    unescape_html(sanitize(string, tags: allowed_tags))
  end

  def strip_title(title)
    title = strip_html(title)
    title.gsub(' | Gemeente Deventer', '')
         .gsub('- Deventer', '')
  end

  def strip_description(description)
    result = strip_html(description, allowed_tags: %w(b))
    # Remove date and dots on beginning (e.g  12 aug 2011 ... )
    result = result.gsub(/[0-9]{1,2} .{1,10} 20[0-9]{2} (<b>)?\.{3}(<\/b>)? /, '')

    # Remove "Laatst gewijzigd: 02 november 2011 om 16:06"
    result = result.gsub(/Laatst gewijzigd: [0-9]{1,2} [a-zA-Z]{1,10} [0-9]{4} om [0-9]{1,2}:[0-9]{1,2}\. /, '')
    result

  end

  # See https://github.com/rails/rails/issues/12672
  def unescape_html safe_buffer
    string = String.new(safe_buffer)
    unescaped_string = CGI.unescapeHTML(string)
    ActiveSupport::SafeBuffer.new(unescaped_string)
  end
end
