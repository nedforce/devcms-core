require File.dirname(__FILE__) + '/../../test_helper'

class Admin::WeblogsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_weblog
    login_as :sjoerd    
    
    get :show, :parent_node_id => nodes(:devcms_weblog_archive_node), :id => weblogs(:henk_weblog).id
    assert_response :success
    assert assigns(:weblog)
    assert_equal weblogs(:henk_weblog).node, assigns(:node)
  end
  
  def test_should_get_index
    login_as :sjoerd
    
    get :index, :node => nodes(:henk_weblog_node).id
    assert_response :success
    assert assigns(:weblog_node)
  end
  
  def test_should_get_index_for_year
    login_as :sjoerd
    
    get :index, :super_node => nodes(:henk_weblog_node).id, :year => '2008'
    assert_response :success
    assert assigns(:weblog_node)
    assert assigns(:year)
  end
  
  def test_should_get_index_for_year_and_month
    login_as :sjoerd
    
    get :index, :super_node => nodes(:henk_weblog_node).id, :year => '2008', :month => '1'
    assert_response :success
    assert assigns(:weblog_node)
    assert assigns(:year)
    assert assigns(:month)
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => weblogs(:henk_weblog).id
    assert_response :success
    assert assigns(:weblog)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => weblogs(:henk_weblog).id, :weblog => { :title => 'foo' }
    assert_response :success
    assert assigns(:weblog)
    assert_equal 'foo', assigns(:weblog).title
  end

  def test_should_update_weblog
    login_as :sjoerd
    
    put :update, :id => weblogs(:henk_weblog).id, :weblog => {:title => 'updated title', :description => 'updated description' }
    assert_response :success
    assert_equal 'updated title', assigns(:weblog).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    weblog = weblogs(:henk_weblog)
    old_title = weblog.title
    put :update, :id => weblog, :weblog => {:title => 'updated title', :description => 'updated description' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:weblog).title
    assert_equal old_title, weblog.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    weblog = weblogs(:henk_weblog)
    old_title = weblog.title
    put :update, :id => weblog, :weblog => {:title => nil, :description => 'updated description' }, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:weblog).errors.on(:title)
    assert_equal old_title, weblog.reload.title
    assert_template 'edit'
  end
  
  def test_should_not_update_weblog
    login_as :sjoerd
    
    put :update, :id => weblogs(:henk_weblog).id, :weblog => {:title => nil}
    assert_response :unprocessable_entity
    assert assigns(:weblog).errors.on(:title)
  end
 
end