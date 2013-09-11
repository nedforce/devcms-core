module SearchHelper

  def highlighted_title_link(result, url)
    if result.highlighted_title.blank?
      link_to(highlight(white_list(result.title), @query.split, :higlighter => '<span class="searchHighlight">\1</span>'), url)
    else
      link_to(white_list(result.highlighted_title, :tags => ["span"], :attributes => ["class"]), url)
    end
  end

  def highlighted_content(result)
    if result.highlighted_content.blank?
      highlight(truncate_html(white_list(result.content), :length => 200), @query.split, :higlighter => '<span class="searchHighlight">\1</span>')
    else
      white_list(result.highlighted_content, :tags => ["span"], :attributes => ["class"])
    end
  end

  def show_search_results_index(prefix = "Results")
    first_page_record = (@results.current_page-1)*@results.limit_value+1    
    last_page_record  = @results.current_page*@results.limit_value
    last_page_record  = @results.size if @results.size < last_page_record    

    result = "#{prefix} <strong>"    
    result << first_page_record.to_s + ' - '
    result <<  last_page_record.to_s + '</strong>'
    raw result
  end

  def print_content_type(content_type)
    case(content_type)
      when 'Product'
        t('search.products')
      when 'Permit'
        t('search.permits')
      when 'NewsItem'
        t('search.news_items')
      when 'CalendarItem'
        t('search.calendar_items')
      when 'Legislation'
        t('search.legislations')
      when 'Attachment'
        t('search.attachments')
      else
        t('search.common_pages')
    end
  end
end
