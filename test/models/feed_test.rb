require File.expand_path('../../test_helper.rb', __FILE__)
require 'fakeweb'

# Unit tests for the +Feed+ model.
class FeedTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    FakeWeb.register_uri(:get, 'http://office.nedforce.nl/correct.rss', body: get_file_as_string('files/nedforce_feed.xml'))
    FakeWeb.register_uri(:get, 'http://office.nedforce.nl/wrong.rss',   body: 'this is a not a valid feed')
    FakeWeb.register_uri(:get, 'http://office.nedforce.nl/empty.rss',   body: nil)

    @feed = feeds(:nedforce_feed)

    # Retrieves the XML content from the location specified by +url+.
    @feed.send(:save!)
  end

  test 'should create feed and get xml' do
    assert_difference 'Feed.count' do
      feed = create_feed
      assert_not_nil feed.xml
    end
  end

  test 'should require url' do
    assert_no_difference 'Feed.count' do
      feed = create_feed(url: nil)
      assert feed.errors[:url].any?
    end
  end

  test 'should require valid feed' do
    assert_no_difference 'Feed.count' do
      feed = create_feed(url: 'http://office.nedforce.nl/wrong.rss')
      assert feed.errors[:url].any?
    end
  end

  test 'should only update with valid feed' do
    @feed.send(:update_attributes, url: 'http://office.nedforce.nl/empty.rss')
    current_feed = @feed.reload
    assert_equal feeds(:nedforce_feed).url, current_feed.url
    assert_not_nil current_feed.parsed_feed
  end

  test 'should not update xml with no response' do
    @feed.url = 'http://diturlbestaatniet'
    @feed.update_feed
    @feed.reload
    assert_equal feeds(:nedforce_feed).xml, @feed.xml
  end

  test 'should not create with no response' do
    feed = create_feed(url: 'http://localhost')
    assert feed.new_record?
  end

  test 'should get parsed feed' do
    assert_not_nil @feed.parsed_feed
    assert_kind_of FeedNormalizer::Feed, @feed.parsed_feed
  end

  test 'should update feed' do
    @feed.update_feed
    assert_not_equal @feed.updated_at, @feed.created_at
    assert @feed.parsed_feed
  end

  test 'should use title if exists and xml title by default' do
    feed = create_feed
    assert feed.title.present?
    feed.title = 'Test!!'
    assert_equal feed.title, 'Test!!'
  end

  protected

  def create_feed(options = {})
    Feed.create({
      parent: nodes(:root_section_node),
      url: 'http://office.nedforce.nl/correct.rss'
    }.merge(options))
  end
end
