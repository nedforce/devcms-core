atom_feed(schema_date: '2008-05-19', url: content_node_url(@weblog_post.node, format: 'atom'), language: 'nl', root_url: content_node_url(@weblog_post.node)) do |feed|
  feed.title(@weblog_post.title)
  feed.subtitle(@weblog_post.preamble, type: 'html') if @weblog_post.preamble
  feed.updated(@comments.first ? @comments.first.created_at : Time.now.utc)
  feed.author do |author|
    author.name(@weblog_post.weblog.user.screen_name)
    author.uri(content_node_url(@weblog_post.weblog.node))
  end

  @comments.each do |comment|
    feed.entry(comment, updated: comment.updated_at, published: comment.created_at, url: content_node_url(@weblog_post.node, anchor: "comment#{comment.id}")) do |entry|
      entry.content(comment.comment, type: 'html')
      feed.author do |author|
        author.name(comment.user.screen_name)
      end
    end
  end
end
