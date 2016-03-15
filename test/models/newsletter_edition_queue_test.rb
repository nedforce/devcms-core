require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterEditionQueueTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  test 'should create newsletter edition queue' do
    assert_difference 'NewsletterEditionQueue.count' do
      create_newsletter_edition_queue
    end
  end

  test 'should require newsletter edition' do
    assert_no_difference 'NewsletterEditionQueue.count' do
      neq = create_newsletter_edition_queue(newsletter_edition: nil)
      assert neq.errors[:newsletter_edition].any?
    end
  end

  test 'should require user' do
    assert_no_difference 'NewsletterEditionQueue.count' do
      neq = create_newsletter_edition_queue(user: nil)
      assert neq.errors[:user].any?
    end
  end

  test 'should require unique user per newsletter edition' do
    assert_difference 'NewsletterEditionQueue.count', 1 do
      create_newsletter_edition_queue
      neq2 = create_newsletter_edition_queue
      assert neq2.errors[:user_id].any?
    end
  end

  protected

  def create_newsletter_edition_queue(options = {})
    NewsletterEditionQueue.create({
      user: users(:henk),
      newsletter_edition: newsletter_editions(:devcms_newsletter_edition)
    }.merge(options))
  end
end
