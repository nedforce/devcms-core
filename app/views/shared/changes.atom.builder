atom_feed(:schema_date => '2008-05-19', :url => content_node_path(@node, :format => 'atom', :action => :changes), :language => 'nl', :root_url => content_node_path(@node)) do |feed|
  feed.title(I18n.t('sitemaps.all_changes'))
  feed.updated(@nodes.first ? @nodes.first.created_at : Time.now.utc)
  feed.author do |author|
    author.name('Gemeente Deventer')
    author.uri('http://www.deventer.nl/')
  end

  for node in @nodes
    feed.entry(node, :updated => node.content.updated_at, :published => node.content.publication_start_date, :url => content_node_url(node)) do |entry|
      entry.title(node.content.content_title, :type => 'html')
    end
  end
end