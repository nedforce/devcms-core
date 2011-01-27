require File.dirname(__FILE__) + '/../test_helper'

class NewsletterEditionMailerWorkerTest < ActiveSupport::TestCase
  def setup
    @newsletter_edition_mailer_worker = NewsletterEditionMailerWorker.new
  end

  def test_should_build_queue_for_unpublished
    edition = newsletter_editions(:example_newsletter_edition)
    assert_difference 'NewsletterEditionQueue.count', edition.newsletter_archive.users.size do
      assert 'unpublished', edition.published
      @newsletter_edition_mailer_worker.send(:get_queue_for, edition)
      assert 'publishing', edition.published
    end
  end
  
  def test_should_resume_queue_for_publishing
    edition = newsletter_editions(:devcms_newsletter_edition)
    assert_no_difference 'NewsletterEditionQueue.count' do
      assert 'publishing', edition.published
      queue = @newsletter_edition_mailer_worker.send(:get_queue_for, edition)
      assert 2, queue.size
    end
  end
end
