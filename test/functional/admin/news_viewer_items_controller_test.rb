require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsViewerItemsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @news_viewer = create_news_viewer
    @news_viewer_item = create_news_viewer_item
  end

  def test_should_json_get_index
    login_as :sjoerd
    get :index, :news_viewer_id => @news_viewer.id, :format => 'json'
    assert_response :success
    assert assigns(:items)
  end

  def test_should_get_available_news_items
    login_as :sjoerd
    get :available_news_items, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id
    assert_response :success
  end

  def test_should_xml_get_available_news_items
    login_as :sjoerd
    get :available_news_items, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id, :format => 'xml'
    assert_response :success
    assert assigns(:news_items)
    assert assigns(:available_news_items)
    assert assigns(:available_news_items_count)
  end

  def test_should_page_for_extjs
    login_as :sjoerd

    create_news_viewer_item(:news_item_id => create_news_item(:publication_start_date => 4.days.ago).id)
    create_news_viewer_item(:news_item_id => create_news_item(:publication_start_date => 8.days.ago).id)
    create_news_viewer_item(:news_item_id => create_news_item(:publication_start_date => 16.days.ago).id)

    post :available_news_items, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id, :start => '0', :limit => '2', :format => 'xml'
    assert_response :success
    assert_equal 2, assigns(:available_news_items).size
  end

  def test_should_xml_create_news_viewer_item
    login_as :sjoerd

    post :create, :news_viewer_id => @news_viewer.id, :news_item_id => create_news_item(:publication_start_date => 4.days.ago).id, :format => 'xml'
    assert_response :success
    assert assigns(:news_viewer_item)
  end

  def test_should_xml_delete_news_viewer_item_with_news_item_id
    login_as :sjoerd
    delete :delete_news_item, :news_viewer_id => @news_viewer.id, :news_item_id => news_items(:devcms_news_item).id, :format => 'xml'
    assert_response :success
  end

  def test_should_update_positions
    login_as :sjoerd

    nve = create_news_viewer_item
    assert_nil @news_viewer_item.position
    assert_nil nve.position

    put :update_positions, :news_viewer_id => @news_viewer.id, :items => [@news_viewer_item.id, nve.id]
    assert_equal 0, @news_viewer_item.reload.position
    assert_equal 1, nve.reload.position

    put :update_positions, :news_viewer_id => @news_viewer.id, :items => [nve.id, @news_viewer_item.id]
    assert_equal 1, @news_viewer_item.reload.position
    assert_equal 0, nve.reload.position
  end

protected

  def create_news_viewer(options = {})
    NewsViewer.create({ :parent => nodes(:economie_section_node), :publication_start_date => 1.day.ago, :title => 'General NewsViewer', :description => 'Gecombineerd nieuws' }.merge(options))
  end

  def create_news_viewer_item(options = {})
    login_as :sjoerd
    post :create, { :news_viewer_id => @news_viewer.id, :news_item_id => create_news_item.id }.merge(options)
    assigns(:news_viewer_item)
  end

  def create_news_item(options = {})
    NewsItem.create({ :parent => nodes(:devcms_news_node), :publication_start_date => 1.day.ago, :title => 'Slecht weer!', :body => 'Het zonnetje schijnt niet en de mensen zijn ontevreden.' }.merge(options))
  end
end
