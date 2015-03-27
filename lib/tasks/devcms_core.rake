namespace :devcms do
  namespace :newsletters do
    desc 'Send newsletter editions'
    task(:send => :environment) do
      NewsletterEditionMailerWorker.new.send_newsletter_editions
    end
  end

  namespace :feeds do
    desc 'Update feeds'
    task(:update => :environment) do
      FeedWorker.new.update_feeds
    end
  end

  namespace :news_viewers do
    desc 'Update news items'
    task(:update => :environment) do
      NewsViewer.update_news_items
    end
  end
end
