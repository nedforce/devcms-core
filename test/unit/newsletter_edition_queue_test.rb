require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterEditionQueueTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_create_newsletter_edition_queue
    assert_difference 'NewsletterEditionQueue.count' do
      create_newsletter_edition_queue
    end
  end
  
  def test_should_require_newsletter_edition
    assert_no_difference 'NewsletterEditionQueue.count' do
      neq = create_newsletter_edition_queue(:newsletter_edition => nil)
      assert neq.errors[:newsletter_edition].any?
    end
  end

  def test_should_require_user
    assert_no_difference 'NewsletterEditionQueue.count' do
      neq = create_newsletter_edition_queue(:user => nil)
      assert neq.errors[:user].any?
    end
  end

  def test_should_require_unique_user_per_newsletter_edition
    assert_difference 'NewsletterEditionQueue.count', 1 do
      neq1 = create_newsletter_edition_queue
      neq2 = create_newsletter_edition_queue
      assert neq2.errors[:user_id].any?
    end
  end

  protected

  def create_newsletter_edition_queue(options = {})
    NewsletterEditionQueue.create({ :user => users(:henk), :newsletter_edition => newsletter_editions(:devcms_newsletter_edition) }.merge(options))
  end
end
