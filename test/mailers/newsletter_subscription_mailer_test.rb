require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterSubscriptionMailerTest < ActionMailer::TestCase
  setup do
    @newsletter_edition = newsletter_editions(:example_newsletter_edition)
  end

  def test_edition_for_noreply
    @newsletter_edition = newsletter_editions(:devcms_newsletter_edition)
    @user = users(:roderick)
    create_and_test_default
    assert Settler[:mail_from_address] =~ /#{@response.from.to_s}/
  end

  def test_edition_for_custom_reply
    @user = users(:arthur)
    create_and_test_default
    assert @response.from.to_s =~ /webmaster@example\.nl/
  end

  def test_no_edition_for_non_subscriber
    user = users(:roderick)
    assert_raise (RuntimeError) { NewsletterSubscriptionMailer.edition_for(@newsletter_edition, user).deliver_now }
  end

  def test_should_render_newsletter_header_image
    @newsletter_edition.header_image_node = Image.create({ :parent => nodes(:devcms_news_item_node), :title => 'Dit is een image.', :file => fixture_file_upload('files/test.jpg') }).node
    assert NewsletterSubscriptionMailer.edition_for(@newsletter_edition, users(:arthur)).parts.second.body.include?('http://www.example.com/nieuws-voor-iedereen/dit-is-een-image/newsletter_banner.jpg')
  end

  protected

  def create_and_test_default
    @response = NewsletterSubscriptionMailer.edition_for(@newsletter_edition, @user).deliver_now
    body = @response.parts.first.body

    assert @response.to.to_s =~ /#{@user.email_address}/
    assert @response.subject =~ /#{@newsletter_edition.title}/
    assert body =~ /#{@newsletter_edition.body}/

    @newsletter_edition.items.each do |item|
      assert body =~ /#{item.title}/
      if item.respond_to?(:preamble)
        assert body =~ /#{item.preamble}/
      else
        assert body =~ /#{item.body}/
      end
    end
  end
end
