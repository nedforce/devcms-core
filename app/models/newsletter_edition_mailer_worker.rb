# This model is used to represent a worker that takes care of sending newsletters.
#
class NewsletterEditionMailerWorker
  # Returns the used logger.
  def logger
    RAILS_DEFAULT_LOGGER
  end

  # Send all newsletter editions.
  def send_newsletter_editions
    logger.info 'Finding newsletter editions to send...'
    editions = NewsletterEdition.all(:include => :node, :conditions => [ 'nodes.publishable = ? AND published <> ? AND nodes.publication_start_date <= ?', true, 'published', Time.now ])
    logger.info "Found #{editions.size} editions to send."
    editions.each do |edition|
      publish_newsletter_edition(edition)
    end
  end

  # Publish the given +newsletter_edition+.
  def publish_newsletter_edition(newsletter_edition)
    logger.info "#{newsletter_edition.id}: Started."
    queue = get_queue_for(newsletter_edition)
    if queue
      logger.info "#{newsletter_edition.id}: Now sending..."
      queue.each { |queued_subscription| send_queued_subscription(queued_subscription) }
      logger.info "#{newsletter_edition.id}: Done sending."
      newsletter_edition.update_attribute(:published, 'published')
    end
  end

  # Send the given +queued_subscription+.
  def send_queued_subscription(queued_subscription)
    # Err on the side of caution: first remove us from the queue, then
    # start sending. This will prevent multiple deliveries should something
    # crash or bail out.
    if queued_subscription.destroy
      begin
        NewsletterSubscription.deliver_edition_for(queued_subscription.newsletter_edition, queued_subscription.user)
      rescue Exception => e
        logger.info "#{queued_subscription.newsletter_edition.id}: Could not send to user #{queued_subscription.user.id}."
        logger.info "#{queued_subscription.newsletter_edition.id}: #{e.message}."
      end
    else
      logger.info "#{queued_subscription.newsletter_edition.id}: Could not remove user #{queued_subscription.user.id} from the queue, postponing!"
    end
  end

  protected

  # Build the queue for the given +newsletter_edition+.
  def build_queue_for(newsletter_edition)
    NewsletterEditionQueue.transaction do
      subscribers = newsletter_edition.newsletter_archive.users
      logger.info "#{newsletter_edition.id}: Queueing #{subscribers.size} subscriptions."
      subscribers.each do |subscriber|
        NewsletterEditionQueue.create(:user => subscriber, :newsletter_edition => newsletter_edition)
      end
      newsletter_edition.update_attribute(:published, 'publishing')
      NewsletterEditionQueue.all(:conditions => { :newsletter_edition_id => newsletter_edition.id })
    end
  end

  # Get the queue for the given +newsletter_edition+.
  def get_queue_for(newsletter_edition)
    queue = nil
    if newsletter_edition.published == 'publishing'
      logger.info "#{newsletter_edition.id}: Resuming from existing queue."
      queue = NewsletterEditionQueue.all(:conditions => { :newsletter_edition_id => newsletter_edition.id })
      logger.info "#{newsletter_edition.id}: Found #{@queue.size} queued subscriptions." rescue nil
    else
      logger.info "#{newsletter_edition.id}: Building new publishing queue."
      queue = build_queue_for(newsletter_edition) 
    end

    unless queue
      logger.info "#{newsletter_edition.id}: Could not resume or build queue, aborting."
      return false
    end

    queue
  end
end
