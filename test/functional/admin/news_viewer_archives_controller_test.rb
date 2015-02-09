require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsViewerArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @news_viewer = create_news_viewer
    @news_viewer_archive = create_news_viewer_archive
  end

  def test_should_xml_create_news_viewer_archive
    login_as :sjoerd

    post :create, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id, :format => 'xml'
    assert_response :success
    assert assigns(:news_viewer_archive)
  end

  def test_should_xml_delete_news_viewer_archive_with_news_archive_id
    login_as :sjoerd
    delete :delete_news_archive, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id, :format => 'xml'
    assert_response :success
  end

  protected

  def create_news_viewer(options = {})
    NewsViewer.create({ :parent => nodes(:economie_section_node), :publication_start_date => 1.day.ago, :title => 'General NewsViewer', :description => 'Gecombineerd nieuws' }.merge(options))    
  end

  def create_news_viewer_archive(options = {})
    login_as :sjoerd

    post :create, { :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id }.merge(options)

    assigns(:news_viewer_archive)
  end
end
