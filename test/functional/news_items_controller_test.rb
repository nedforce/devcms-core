require File.expand_path('../../test_helper.rb', __FILE__)

class NewsItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_news_item
    get :show, :id => news_items(:devcms_news_item).id
    assert_response :success
    assert assigns(:news_item)
    assert_equal nodes(:devcms_news_item_node), assigns(:node)
  end

  def should_not_show_unpublished_news_items
    news_items(:devcms_news_item).update_attribute(:publication_end_date, DateTime.now - 1.day)
    get :show, :id => news_items(:devcms_news_item).id
    assert flash.key?(:warning)
    assert_response :redirect
  end
end
