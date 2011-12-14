require File.dirname(__FILE__) + '/../test_helper'

class ForumTopicsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_forum_topic
    get :show, :id => forum_topics(:bewoners_forum_topic_wonen).id
    assert_response :success
    assert assigns(:forum_topic)
    assert_equal nodes(:bewoners_forum_topic_wonen_node), assigns(:node)
  end
  
end
