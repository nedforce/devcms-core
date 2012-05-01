atom_feed(:schema_date => '2008-05-19', :url => content_node_url(@weblog.node, :format => 'atom'), :language => 'nl', :root_url => content_node_url(@weblog.node)) do |feed|
  feed.title(@weblog.title)
  feed.subtitle(@weblog.description, :type => 'html')
  feed.updated(@weblog_posts.first ? @weblog_posts.first.created_at : Time.now.utc)
  feed.author do |author|
    author.name(@weblog.user.screen_name)
    author.uri(content_node_url(@weblog.node))
  end

   @weblog_posts.each do |weblog_post|
    feed.entry(weblog_post, :updated => weblog_post.updated_at, :published => weblog_post.publication_start_date, :url => content_node_url(weblog_post.node)) do |entry|
      entry.title(weblog_post.title)
      entry.summary(weblog_post.preamble, :type => 'html') if weblog_post.preamble
      entry.content(weblog_post.body,     :type => 'html')
    end
  end
end
