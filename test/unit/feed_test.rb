require File.expand_path('../../test_helper.rb', __FILE__)
require 'fakeweb'

class FeedTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
    
  def setup
    FakeWeb.register_uri(:get, "http://office.nedforce.nl/correct.rss", :body => get_file_as_string('files/nedforce_feed.xml'))
    FakeWeb.register_uri(:get, "http://office.nedforce.nl/wrong.rss", :body => 'this is a not a valid feed')
    FakeWeb.register_uri(:get, "http://office.nedforce.nl/empty.rss", :body => nil)
    
    @feed = feeds(:nedforce_feed)
    @feed.send(:save!) # Retrieves the XML content from the location specified by +url+
  end
  
  def test_should_create_feed_and_get_xml
    assert_difference 'Feed.count' do
      feed = create_feed
      assert_not_nil feed.xml
    end
  end
  
  def test_should_require_url
    assert_no_difference 'Feed.count' do
      feed = create_feed(:url => nil)
      assert feed.errors[:url].any?
    end
  end
  
  def test_should_require_valid_feed
    assert_no_difference 'Feed.count' do
      feed = create_feed(:url => "http://office.nedforce.nl/wrong.rss")
      assert feed.errors[:url].any?
    end
  end
  
  def test_should_only_update_with_valid_feed
    @feed.send(:update_attributes, :url => "http://office.nedforce.nl/empty.rss")
    current_feed = @feed.reload
    assert_equal feeds(:nedforce_feed).url, current_feed.url
    assert_not_nil current_feed.parsed_feed
  end
  
  def test_should_not_update_xml_with_no_response
    @feed.url = "http://diturlbestaatniet"
    @feed.update_feed
    assert_equal feeds(:nedforce_feed).xml, @feed.xml
  end
  
  def test_should_not_create_with_no_response
    feed = create_feed(:url => "http://localhost")
    assert feed.new_record?
  end
   
  def test_should_get_parsed_feed
    assert_not_nil @feed.parsed_feed
    assert_kind_of FeedNormalizer::Feed, @feed.parsed_feed
  end
  
  def test_should_update_feed
    @feed.update_feed
    assert_not_equal @feed.updated_at, @feed.created_at
    assert @feed.parsed_feed
  end

  def test_should_use_title_if_exists_and_xml_title_by_default
    feed = create_feed
    assert !feed.title.blank?
    feed.title = "Test!!"
    assert_equal feed.title, "Test!!"
  end
  
protected

  def create_feed(options = {})
    Feed.create({ :parent => nodes(:root_section_node), :url => 'http://office.nedforce.nl/correct.rss' }.merge(options))
  end
  
end
