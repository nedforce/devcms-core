# This model is used to represent a worker that updates the RSS feeds.
#
class FeedWorker
  # Returns the used logger.
  def logger
    Rails.logger
  end

  # Updates all feeds.
  def update_feeds
    logger.info 'Updating all feeds...'
    Feed.all.each do |feed|
      logger.info "Updating feed #{feed.id} from url #{feed.url}..."
      feed.update_feed
    end
  end
end
