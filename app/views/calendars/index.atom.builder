atom_feed(:schema_date => '2008-05-19', :url => calendars_url(:format => 'atom'), :language => 'nl') do |feed|
  feed.title(@feed_title || I18n.t('calendars.all_calendar_items'))
  feed.updated(@calendar_items.first ? @calendar_items.first.created_at : Time.now.utc)
  feed.author do |author|
    author.name(Settler[:site_name])
    author.uri("http://#{Settler[:host]}")
  end

  for calendar_item in @calendar_items
    feed.entry(calendar_item, :updated => calendar_item.updated_at, :published => calendar_item.created_at, :url => content_node_url(calendar_item.node)) do |entry|
      entry.title("#{calendar_item.title} (#{l(calendar_item.start_time, :format => :short)})")
      entry.content(calendar_item.body, :type => 'html')
    end
  end
end
