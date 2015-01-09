require File.expand_path('../../test_helper.rb', __FILE__)

class SocialMediaLinksBoxTest < ActiveSupport::TestCase

  def test_should_create_social_media_links_box
    assert_difference 'SocialMediaLinksBox.count' do
      smlb = create_social_media_links_box
      assert !smlb.new_record?, smlb.errors.full_messages.to_sentence
    end
  end

  def test_should_require_title
    assert_no_difference 'SocialMediaLinksBox.count' do
      smlb = create_social_media_links_box(title: nil)
      assert smlb.errors[:title].any?
    end
  end

  def test_should_not_require_url
    assert_difference 'SocialMediaLinksBox.count' do
      smlb = create_social_media_links_box(twitter_url: nil)
      assert !smlb.new_record?, smlb.errors.full_messages.to_sentence
    end
  end

  protected

  def create_social_media_links_box(options = {})
    SocialMediaLinksBox.create({
      title:        'Social Media Links Box',
      twitter_url:  'http://www.twitter.com',
      facebook_url: 'http://www.facebook.com',
      linkedin_url: 'http://www.linkedin.com',
      youtube_url:  'http://www.youtube.com',
      flickr_url:   'http://www.flickr.com',
      parent:       nodes(:root_section_node)
    }.merge(options))
  end
end
