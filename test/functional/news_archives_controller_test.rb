require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +NewsArchivesController+.
class NewsArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should show news archive' do
    get :show, id: news_archives(:devcms_news).id
    assert_response :success
    assert assigns(:news_archive)
    assert assigns(:latest_news_items)
    assert !(assigns(:latest_news_items).size > 8)
    assert_nil assigns(:news_items_for_table)
    assert_equal nodes(:devcms_news_node), assigns(:node)
  end

  test 'should show news archive atom' do
    get :show, id: news_archives(:devcms_news).id, format: 'atom'
    assert_response :success
  end

  test 'should show news archive rss' do
    get :show, id: news_archives(:devcms_news).id, format: 'rss'
    assert_response :success
  end

  test 'should show news archive archive action' do
    get :archive, id: news_archives(:devcms_news).id, month: Date.today.month, year: Date.today.year
    assert_response :success
    assert assigns(:news_archive)
    assert assigns(:start_date)
    assert assigns(:end_date)
    assert assigns(:news_items)
  end

  test 'should show news archive archive action from search' do
    get :archive, id: news_archives(:devcms_news).id, date: { month: Date.today.month, year: Date.today.year }
    assert_response :success
    assert assigns(:news_archive)
    assert assigns(:start_date)
    assert assigns(:end_date)
    assert assigns(:news_items)
  end
end
