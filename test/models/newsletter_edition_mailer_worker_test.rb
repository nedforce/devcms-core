require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterEditionMailerWorkerTest < ActiveSupport::TestCase
  setup do
    @newsletter_edition_mailer_worker = NewsletterEditionMailerWorker.new

    ActionMailer::Base.deliveries.clear
  end

  test 'should build queue for unpublished newsletters' do
    edition = newsletter_editions(:example_newsletter_edition)

    assert_difference 'NewsletterEditionQueue.count', edition.newsletter_archive.users.size do
      assert_equal 'unpublished', edition.published
      @newsletter_edition_mailer_worker.send(:get_queue_for, edition)
      assert_equal 'publishing', edition.published
    end
  end

  test 'should resume queue for publishing newsletters' do
    edition = newsletter_editions(:devcms_newsletter_edition)

    assert_equal 'publishing', edition.published
    assert_no_difference 'NewsletterEditionQueue.count' do
      queue = @newsletter_edition_mailer_worker.send(:get_queue_for, edition)
      assert_equal 2, queue.size
    end
  end

  test 'should send queued subscription' do
    edition = newsletter_editions(:devcms_newsletter_edition)
    queue = @newsletter_edition_mailer_worker.send(:get_queue_for, edition)

    assert_equal 2, queue.size
    assert_difference 'ActionMailer::Base.deliveries.size' do
      @newsletter_edition_mailer_worker.send_queued_subscription(queue.first)
    end
    assert_equal 1, queue.size
  end

  test 'should publish newsletter edition' do
    edition = newsletter_editions(:devcms_newsletter_edition)

    assert_difference 'ActionMailer::Base.deliveries.size', 2 do
      @newsletter_edition_mailer_worker.publish_newsletter_edition(edition)
    end
    assert 'published', edition.published
  end

  test 'should send newsletter editions' do
    assert_equal 0, NewsletterEdition.published.size
    assert_equal 2, NewsletterEdition.unpublished.size
    assert_equal 1, NewsletterEdition.publishing.size
    assert_equal 3, NewsletterEdition.to_publish.size

    @newsletter_edition_mailer_worker.send_newsletter_editions

    assert_equal 3, NewsletterEdition.published.size
    assert_equal 0, NewsletterEdition.unpublished.size
    assert_equal 0, NewsletterEdition.publishing.size
    assert_equal 0, NewsletterEdition.to_publish.size
  end
end
