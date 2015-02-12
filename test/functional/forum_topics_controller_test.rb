require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +ForumTopicsController+.
class ForumTopicsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show forum topic' do
    get :show, id: forum_topics(:bewoners_forum_topic_wonen).id
    assert_response :success
    assert assigns(:forum_topic)
    assert_equal nodes(:bewoners_forum_topic_wonen_node), assigns(:node)
  end
end
