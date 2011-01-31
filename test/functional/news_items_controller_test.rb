require File.dirname(__FILE__) + '/../test_helper'

class NewsItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_news_item
    get :show, :id => news_items(:devcms_news_item).id
    assert_response :success
    assert assigns(:news_item)
    assert_equal nodes(:devcms_news_item_node), assigns(:node)
  end
 
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
  
  def should_not_show_unpublished_news_items
    news_items(:devcms_news_item).update_attribute(:publication_end_date, DateTime.now-1.day)
    get :show, :id => news_items(:devcms_news_item).id
    assert flash.has_key?(:warning)
    assert_response :redirect
  end
  
end