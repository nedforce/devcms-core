atom_feed(:schema_date => '2008-05-19', :url => content_node_url(@news_archive.node, :format => 'atom'), :language => 'nl', :root_url => content_node_url(@news_archive.node)) do |feed|
  feed.title(@news_archive.title)
  feed.subtitle(@news_archive.description, :type => 'html')
  feed.updated(@news_items.results.first ? @news_items.results.first.created_at : Time.now.utc)
  feed.author do |author|
    author.name(Settler[:site_name])
    author.uri("http://#{Settler[:host]}")
  end

  for news_item in @news_items
    feed.entry(news_item, :updated => news_item.updated_at, :published => news_item.publication_start_date, :url => content_node_url(news_item.node)) do |entry|
      entry.title(news_item.title)
      entry.summary(news_item.preamble, :type => 'html') if news_item.preamble
      entry.content(news_item.body,     :type => 'html')
    end
  end
end
