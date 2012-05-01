require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterEditionMailerWorkerTest < ActiveSupport::TestCase
  def setup
    @newsletter_edition_mailer_worker = NewsletterEditionMailerWorker.new
  end

  def test_should_build_queue_for_unpublished
    edition = newsletter_editions(:example_newsletter_edition)
    assert_difference 'NewsletterEditionQueue.count', edition.newsletter_archive.users.size do
      assert_equal 'unpublished', edition.published
      @newsletter_edition_mailer_worker.send(:get_queue_for, edition)
      assert_equal 'publishing', edition.published
    end
  end
  
  def test_should_resume_queue_for_publishing
    edition = newsletter_editions(:devcms_newsletter_edition)
    assert_no_difference 'NewsletterEditionQueue.count' do
      assert_equal 'publishing', edition.published
      queue = @newsletter_edition_mailer_worker.send(:get_queue_for, edition)
      assert_equal 2, queue.size
    end
  end
end
