require File.dirname(__FILE__) + '/../test_helper'

class WeblogsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_weblog
    get :show, :id => weblogs(:henk_weblog).id
    assert_response :success
    assert assigns(:weblog)
    assert_equal nodes(:henk_weblog_node), assigns(:node)
  end
  
  # See Redmine #2448
  def test_show_should_render_many_posts_correctly
    blog = Weblog.create!(:parent => weblog_archives(:devcms_weblog_archive).node, 
                                      :user => users(:gerjan), 
                                      :title => "Very Active Blog", 
                                      :description => "Beschrijving komt hier.",
                                      :publication_start_date => 2.days.ago
                                      )
    1.upto(10) do |n|
      WeblogPost.create!(:parent =>blog.node, :title => "Test Post #{n}", :body => '<p>Text</p>', :publication_start_date => 1.day.ago)
    end 
    
    get :show, :id => blog.id
    assert_response :success
    assert assigns(:weblog)
    assert assigns(:latest_weblog_posts)
    assert assigns(:weblog_posts_for_table)
  end
  
  def test_should_show_weblog_atom
    get :show, :id => weblogs(:henk_weblog).id, :format => 'atom'
    assert_response :success
  end
 
  def test_should_get_new_for_user_that_hasnt_got_a_weblog_yet
    login_as :sjoerd
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id
    assert assigns(:weblog)
    assert_response :success
  end
  
  def test_should_not_get_new_for_user_that_already_has_a_weblog
    login_as :henk
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id
    assert_response :redirect
  end
  
  def test_should_not_get_new_for_non_user
    get :new, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id
    assert_response :redirect
  end
  
  def test_should_create_weblog_for_user_that_hasnt_got_a_weblog_yet
    login_as :sjoerd
    
    assert_difference('Weblog.count', 1) do
      create_weblog
      assert_response :redirect
      assert !assigns(:weblog).new_record?, :message => assigns(:weblog).errors.full_messages.join('; ')
      assert_equal users(:sjoerd), assigns(:weblog).user
    end
  end
      
  def test_should_not_create_weblog_with_invalid_title
    login_as :sjoerd
    assert_no_difference('Weblog.count') do
      create_weblog(:title => nil)
      assert_response :success
      assert assigns(:weblog).errors.on(:title)
    end
  end
  
  def test_should_not_create_weblog_for_user_that_already_has_a_weblog
    login_as :henk
    assert_no_difference('Weblog.count') do
      create_weblog
      assert_response :redirect
    end
  end
  
  def test_should_not_create_weblog_for_non_user
    assert_no_difference('Weblog.count') do
      create_weblog()
      assert_response :redirect
    end
  end
  
  def test_should_get_edit_for_owner
    login_as :henk
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    assert_response :success
    assert assigns(:weblog)
  end
  
  def test_should_get_edit_for_admin
    login_as :sjoerd
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    assert_response :success
    assert assigns(:weblog)
  end
  
  def test_should_not_get_edit_for_non_owner
    login_as :gerjan
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    assert_response :redirect
  end
  
  def test_should_not_get_edit_for_non_user
    get :edit, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    assert_response :redirect
   end
  
  def test_should_update_weblog_for_owner
    login_as :henk
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id, :weblog => { :title => 'updated title' }
    assert_response :redirect
    assert_equal 'updated title', assigns(:weblog).title
  end
  
  def test_should_update_weblog_for_admin
    login_as :sjoerd
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id, :weblog => { :title => 'updated title' }
    assert_response :redirect
    assert_equal 'updated title', assigns(:weblog).title
  end
  
  def test_should_not_update_weblog_with_invalid_title
    login_as :henk
    old_title = weblogs(:henk_weblog).title
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id, :weblog => { :title => nil }
    assert_response :success
    assert assigns(:weblog).errors.on(:title)
    assert_equal old_title, weblogs(:henk_weblog).reload.title
  end
  
  def test_should_not_update_weblog_for_non_user
    old_title = weblogs(:henk_weblog).title
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id, :weblog => { :title => 'updated title' }
    assert_response :redirect
    assert_equal old_title, weblogs(:henk_weblog).reload.title
  end
  
  def test_should_not_update_weblog_for_non_owner
    login_as :gerjan
    old_title = weblogs(:henk_weblog).title
    put :update, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id, :weblog => { :title => 'updated title' }
    assert_response :redirect
    assert_equal old_title, weblogs(:henk_weblog).reload.title
  end
  
  def test_should_destroy_weblog_for_owner
    login_as :henk
    assert_difference('Weblog.count', -1) do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    end
    assert_response :redirect
  end
  
  def test_should_destroy_weblog_for_admin
    login_as :sjoerd
    assert_difference('Weblog.count', -1) do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    end
    assert_response :redirect
  end
  
  def test_should_not_destroy_weblog_for_non_owner
    login_as :gerjan
    assert_no_difference 'Weblog.count' do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    end
    assert_response :redirect
  end
  
  def test_should_not_destroy_weblog_for_non_user
    assert_no_difference 'Weblog.count' do
      delete :destroy, :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :id => weblogs(:henk_weblog).id
    end
    assert_response :redirect
  end
  
  def test_should_destroy_content_with_delete
    login_as :henk
    assert_difference 'Weblog.count', -1 do
      w = weblogs(:henk_weblog)
      delete :destroy, :weblog_archive_id => w.weblog_archive.id, :id => w.id
    end
  end
  
 protected
  
  def create_weblog(attributes = {}, options = {})
    post :create, { :weblog_archive_id => weblog_archives(:devcms_weblog_archive).id, :weblog => { :title => 'Some title.', :description => 'Some description' }.merge(attributes)}.merge(options)
  end
  
end
