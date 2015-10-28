atom_feed(schema_date: '2008-05-19', url: forum_topic_forum_thread_url(@forum_topic, @forum_thread, format: 'atom'), language: 'nl', root_url: forum_topic_forum_thread_url(@forum_topic, @forum_thread)) do |feed|
  feed.title(@forum_thread.title)
  feed.subtitle(@forum_topic.description, type: 'html')
  feed.updated(@replies.first ? @replies.first.created_at : Time.now.utc)
  feed.author do |author|
    author.name(@forum_thread.user.screen_name)
  end

  for reply in @replies[0..24]
    feed.entry(reply, updated: reply.updated_at, published: reply.created_at, url: forum_topic_forum_thread_url(@forum_topic, @forum_thread, anchor: "reply#{reply.id}")) do |entry|
      entry.content(reply.body, type: 'html')
      feed.author do |author|
        author.name(reply.user_name)
      end
    end
  end
end
