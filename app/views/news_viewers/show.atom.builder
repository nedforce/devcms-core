atom_feed(:schema_date => '2008-05-19', :url => content_node_url(@news_viewer.node, :format => 'atom'), :language => 'nl', :root_url => content_node_url(@news_viewer.node)) do |feed|
  feed.title(@news_viewer.title)
  feed.subtitle(@news_viewer.description, :type => 'html')
  feed.author do |author|
    author.name('Gemeente Deventer')
    author.uri('http://www.deventer.nl')
  end

  for news_item in @news_items
    feed.entry(news_item, :updated => news_item.updated_at, :published => news_item.publication_start_date, :url => content_node_url(news_item.node)) do |entry|
      entry.title(news_item.title)
      entry.summary(news_item.preamble, :type => 'html') if news_item.preamble
      entry.content(news_item.body,     :type => 'html')
    end
  end
end
