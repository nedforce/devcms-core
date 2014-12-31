require File.expand_path('../../test_helper.rb', __FILE__)
require 'fakeweb'

class FeedsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    FakeWeb.register_uri(:get, 'http://office.nedforce.nl/correct.rss', body: get_file_as_string('files/nedforce_feed.xml'))
  end

  test 'should show feed' do
    get :show, id: feeds(:nedforce_feed).id

    assert_response :success
    assert assigns(:feed)
    assert_equal nodes(:nedforce_feed_node), assigns(:node)
  end
end
