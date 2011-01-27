require File.dirname(__FILE__) + '/../test_helper'

class NewsArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_news_archive
    get :show, :id => news_archives(:devcms_news).id
    assert_response :success
    assert assigns(:news_archive)
    assert assigns(:latest_news_items)
    assert !(assigns(:latest_news_items).size > 8)
    assert_nil assigns(:news_items_for_table)
    assert_equal nodes(:devcms_news_node), assigns(:node)
  end
  
  def test_should_show_news_archive_atom
    get :show, :id => news_archives(:devcms_news).id, :format => 'atom'
    assert_response :success
  end
  
  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end
  
end
