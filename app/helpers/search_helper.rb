module SearchHelper

  def highlighted_title_link(result, url)
    if result.highlighted_title.blank?
      link_to(highlight(white_list(result.title), @query.split, '<span class="searchHighlight">\1</span>'), url)
    else
      link_to(white_list(result.highlighted_title, :tags => ["span"], :attributes => ["class"]), url)
    end
  end

  def highlighted_content(result)
    if result.highlighted_content.blank?
      highlight(truncate_html(white_list(result.content), 200), @query.split, '<span class="searchHighlight">\1</span>')
    else
      white_list(result.highlighted_content, :tags => ["span"], :attributes => ["class"])
    end
  end

  def show_search_results_index(prefix = "Results")
    first_page_record = (@results.page-1)*@results.page_size+1    
    last_page_record  = @results.page*@results.page_size
    last_page_record  = @results.size if @results.size < last_page_record    

    result = "#{prefix} <strong>"    
    result << first_page_record.to_s + ' - '
    result <<  last_page_record.to_s + '</strong>'
    raw result
  end

  def print_category(category)
    default_options = {
     :advanced      => true,
     :query         => '',
     :search_engine => params[:search_engine]
    }
    default_options[:programme] = category.parent ? category.parent_id : category.id
    if category.parent
      link_to(category.parent.name, search_path(default_options)) + 
      ' | ' +
      link_to(category.name, search_path({:project => category.id}.merge(default_options)))
    else
      link_to category.name, search_path(default_options)
    end
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
