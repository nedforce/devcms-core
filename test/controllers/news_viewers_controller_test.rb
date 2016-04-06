require File.expand_path('../../test_helper.rb', __FILE__)

class NewsViewersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @news_viewer = create_news_viewer
  end

  def test_should_show_news_viewer
    get :show, :id => @news_viewer.id
    assert_response :success
    assert assigns(:news_viewer)
    assert assigns(:latest_news_items)
    refute (assigns(:latest_news_items).size > 8)
    assert_nil assigns(:news_items_for_table)
    assert_equal @news_viewer.node, assigns(:node)
  end

  def test_should_show_news_viewer_atom
    get :show, :id => @news_viewer.id, :format => 'atom'
    assert_response :success
  end

  def test_should_show_news_viewer_rss
    get :show, :id => @news_viewer.id, :format => 'rss'
    assert_response :success
  end

private

  def create_news_viewer(options = {})
    NewsViewer.create({ :parent => nodes(:economie_section_node), :publication_start_date => 1.day.ago, :title => 'General NewsViewer', :description => 'Gecombineerd nieuws' }.merge(options))
  end
end
