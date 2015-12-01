namespace :devcms do
  namespace :feeds do
    desc 'Update all feeds'
    task update: :environment do
      FeedWorker.new.update_feeds
    end
  end

  namespace :news_viewer do
    desc 'Update the news items of a news viewer'
    task update_news_items: :environment do
      NewsViewer.update_news_items
    end
  end

  namespace :node do
    desc 'Removes a percentage of the hits of a node'
    task reduce_hit_count: :environment do
      Node.reduce_hit_count
    end

    desc 'Rebuilds the search index'
    task rebuild_index: :environment do
      Node.rebuild_index
    end
  end
end
