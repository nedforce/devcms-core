xml.results do
  xml.tag!('total_count', @available_news_items_count)
  xml.news_items do
    @available_news_items.each do |news_item|
      xml.news_item {
        xml.id(news_item.id)
        xml.title(news_item.title)
        xml.publication_date(news_item.node.publication_start_date)
        xml.checked(@news_items.include?(news_item))
      }
    end
  end
end