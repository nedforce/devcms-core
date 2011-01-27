require File.dirname(__FILE__) + '/../test_helper'

class NewsletterSubscriptionTest < ActionMailer::TestCase
  tests NewsletterSubscription
  
  def test_edition_for_noreply
    @newsletter_edition = newsletter_editions(:devcms_newsletter_edition)
    @user = users(:roderick)
    create_and_test_default
    assert Settler[:mail_from_address] =~ /#{@response.from.to_s}/
  end

  def test_edition_for_custom_reply
    @newsletter_edition = newsletter_editions(:example_newsletter_edition)
    @user = users(:arthur)
    create_and_test_default
    assert @response.from.to_s =~ /webmaster@example\.nl/
  end
  
  def test_no_edition_for_non_subscriber
    newsletter_edition = newsletter_editions(:example_newsletter_edition)
    user = users(:roderick)
    assert_raise (RuntimeError) { NewsletterSubscription.create_edition_for(newsletter_edition, user) }
  end
  
  protected
    def create_and_test_default
      @response = NewsletterSubscription.create_edition_for(@newsletter_edition, @user)

      assert @response.to.to_s =~ /#{@user.email_address}/
      assert @response.subject =~ /#{@newsletter_edition.title}/
      assert @response.body =~ /#{@newsletter_edition.body}/

      for item in @newsletter_edition.items
        assert @response.body =~ /#{item.title}/
        if item.respond_to?(:preamble)
          assert @response.body =~ /#{item.preamble}/
        else
          assert @response.body =~ /#{item.body}/
        end
      end
    end
end
