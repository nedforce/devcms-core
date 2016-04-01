require File.expand_path('../../test_helper.rb', __FILE__)

class SocialMediaLinksBoxTest < ActiveSupport::TestCase
  test 'should create social media links box' do
    assert_difference 'SocialMediaLinksBox.count' do
      smlb = create_social_media_links_box
      refute smlb.new_record?, smlb.errors.full_messages.to_sentence
    end
  end

  test 'should require title' do
    assert_no_difference 'SocialMediaLinksBox.count' do
      smlb = create_social_media_links_box(title: nil)
      assert smlb.errors[:title].any?
    end
  end

  test 'should not require url' do
    assert_difference 'SocialMediaLinksBox.count' do
      smlb = create_social_media_links_box(twitter_url: nil)
      refute smlb.new_record?, smlb.errors.full_messages.to_sentence
    end
  end

  protected

  def create_social_media_links_box(options = {})
    SocialMediaLinksBox.create({
      title:        'Social Media Links Box',
      twitter_url:  'https://www.twitter.com',
      facebook_url: 'https://www.facebook.com',
      linkedin_url: 'https://www.linkedin.com',
      youtube_url:  'https://www.youtube.com',
      flickr_url:   'https://www.flickr.com',
      parent:       nodes(:root_section_node)
    }.merge(options))
  end
end
