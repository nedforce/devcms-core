require File.dirname(__FILE__) + '/../../test_helper'

class Admin::NewsViewerArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @news_viewer = create_news_viewer
    @news_viewer_archive = create_news_viewer_archive
  end

  def test_should_xml_create_news_viewer_archive
    login_as :sjoerd
    arthur = users(:arthur)
    put :create, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id, :format => 'xml'
    assert_response :success
    assert assigns(:news_viewer_archive)
  end

  def test_should_not_xml_create_news_viewer_archive_with_invalid_news_archive
    login_as :sjoerd
    put :create, :news_viewer_id => @news_viewer.id, :news_archive_id => -1, :format => 'xml'
    assert_response :not_found
  end
  
  def test_should_xml_delete_news_viewer_archive_with_news_archive_id
    login_as :sjoerd
    delete :delete_news_archive, :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id, :format => 'xml'
    assert_response :success
  end

  def test_should_not_xml_destroy_news_viewer_archive_with_invalid_news_archive_id
    login_as :sjoerd
    delete :delete_news_archive, :news_viewer_id => @news_viewer.id, :news_archive_id => -1, :format => 'xml'
    assert_response :success
  end

  def test_should_require_roles
    assert_user_can_access :arthur, [ :create, :delete_news_archive ], {:news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id }
    assert_user_can_access :final_editor, [ :create, :delete_news_archive ], {:news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id }
    assert_user_cant_access :editor, [ :create, :delete_news_archive ], {:news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id }
  end

protected

  def create_news_viewer(options = {})
    NewsViewer.create({:parent => nodes(:economie_section_node), :publication_start_date => 1.day.ago, :title => "General NewsViewer", :description => "Gecombineerd nieuws"}.merge(options))    
  end
  
  def create_news_viewer_archive(options = {})
    login_as :sjoerd    
    post :create, { :news_viewer_id => @news_viewer.id, :news_archive_id => news_archives(:devcms_news).id }.merge(options)
    assigns(:news_viewer_archive)
  end 


end
