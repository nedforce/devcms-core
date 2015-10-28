require File.expand_path('../../test_helper.rb', __FILE__)
require 'fakeweb'

class FeedWorkerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    FakeWeb.register_uri(:get, 'http://office.nedforce.nl/correct.rss', body: get_file_as_string('files/nedforce_feed.xml'))

    @feed_worker = FeedWorker.new
  end

  test 'should update all feeds' do
    Feed.create(parent: nodes(:root_section_node), url: 'http://office.nedforce.nl/correct.rss', created_at: 1.day.ago)

    @feed_worker.update_feeds

    Feed.all.each do |feed|
      assert_not_equal feed.updated_at, feed.created_at
    end
  end
end
