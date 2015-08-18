
require File.expand_path('../../test_helper.rb', __FILE__)

class NewsletterArchivesUserTest < ActiveSupport::TestCase
  setup do
    @arthur = users(:arthur)
    @sjoerd = users(:sjoerd)
    @newsletter = newsletter_archives(:example_newsletter_archive)

    assert_includes @arthur.newsletter_archives, @newsletter
    assert_not_includes @sjoerd.newsletter_archives, @newsletter
  end

  test 'validate uniqueness' do

    assert_difference '@sjoerd.newsletter_archives.count', 1 do
      @sjoerd.newsletter_archives << @newsletter
    end

    assert_no_difference '@arthur.newsletter_archives.count' do
      @arthur.newsletter_archives << @newsletter rescue nil
    end
  end

end
