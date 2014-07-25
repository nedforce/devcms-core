require File.expand_path('../../test_helper.rb', __FILE__)

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

  def test_should_show_news_archive_rss
    get :show, :id => news_archives(:devcms_news).id, :format => 'rss'
    assert_response :success
  end

  def test_should_show_news_archive_archive_action
    get :archive, :id => news_archives(:devcms_news).id, :month => Date.today.month, :year => Date.today.year
    assert_response :success
    assert assigns(:news_archive)
    assert assigns(:start_date)
    assert assigns(:end_date)
    assert assigns(:news_items)
  end

  def test_should_show_news_archive_archive_action_from_search
    get :archive, :id => news_archives(:devcms_news).id, :date => { :month => Date.today.month, :year => Date.today.year }
    assert_response :success
    assert assigns(:news_archive)
    assert assigns(:start_date)
    assert assigns(:end_date)
    assert assigns(:news_items)
  end
end
