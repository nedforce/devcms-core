require File.expand_path('../../test_helper.rb', __FILE__)

class ForumPostsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
 
  def test_should_redirect_for_show
    get :show, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :redirect    
  end
  
  def test_should_not_show_for_start_post
    get :show, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_one).id
    assert_response :redirect
  end
  
  def test_should_redirect_for_invalid_forum_topic
    login_as :henk
    get :edit, :forum_topic_id => nil, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :not_found
  end
  
  def test_should_redirect_for_invalid_forum_thread
    login_as :henk
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => nil, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :not_found
  end

  def test_should_redirect_for_invalid_forum_post
    login_as :henk
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one), :id => nil
    assert_response :not_found
  end
 
  def test_should_get_new_for_user
    login_as :gerjan
    get :new, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id
    assert assigns(:forum_post)
    assert_response :success
  end

  def test_should_not_get_new_for_non_user
    get :new, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :redirect
  end
  
  def test_should_create_forum_post_for_user
    login_as :gerjan
    assert_difference('ForumPost.count', 1) do
      create_forum_post
      assert_response :redirect
      assert !assigns(:forum_post).new_record?, assigns(:forum_post).errors.full_messages.join('; ')
      assert_equal users(:gerjan), assigns(:forum_post).user
    end
  end
      
  def test_should_not_create_forum_post_with_invalid_body
    login_as :gerjan
    assert_no_difference('ForumPost.count') do
      create_forum_post(:body => nil)
      assert_response :success
      assert assigns(:forum_post).errors[:body].any?
    end
  end
    
  def test_should_not_create_forum_post_for_non_user
    assert_no_difference('ForumPost.count') do
      create_forum_post()
      assert_response :redirect
    end
  end
  
  def test_should_get_edit_for_owner
    login_as :henk
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :success
    assert assigns(:forum_post)
  end
  
  def test_should_get_edit_for_admin
    login_as :sjoerd
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :success
    assert assigns(:forum_post)
    assert_equal users(:henk).login, assigns(:forum_post).user_name
  end
  
  def test_should_not_get_edit_for_non_owner
    login_as :gerjan
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :redirect
  end
  
  def test_should_not_get_edit_for_non_user
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    assert_response :redirect
  end
  
  def test_should_not_get_edit_for_start_post
    login_as :henk
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_one).id
    assert_response :redirect
  end
  
  def test_should_update_forum_post_for_owner
    login_as :henk
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id, :forum_post => { :body => 'updated body' }
    assert_response :redirect
    assert_equal 'updated body', assigns(:forum_post).body
  end
  
  def test_should_update_forum_post_for_admin
    login_as :sjoerd
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id, :forum_post => { :body => 'updated body' }
    assert_response :redirect
    assert_equal 'updated body', assigns(:forum_post).body
  end
  
  def test_should_not_update_forum_post_with_invalid_title
    login_as :henk
    old_body = forum_posts(:bewoners_forum_post_five).body
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id, :forum_post => { :body => nil }
    assert_response :success
    assert assigns(:forum_post).errors[:body].any?
    assert_equal old_body, forum_posts(:bewoners_forum_post_five).reload.body
  end
    
  def test_should_not_update_forum_post_for_non_owner
    login_as :gerjan
    old_body = forum_posts(:bewoners_forum_post_five).body
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id, :forum_post => { :body => 'updated body' }
    assert_response :redirect
    assert_equal old_body, forum_posts(:bewoners_forum_post_five).reload.body
  end
  
  def test_should_not_update_forum_post_for_non_user
    old_body = forum_posts(:bewoners_forum_post_five).body
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id, :forum_post => { :body => 'updated body' }
    assert_response :redirect
    assert_equal old_body, forum_posts(:bewoners_forum_post_five).reload.body
  end
  
  def test_should_not_update_start_post
    login_as :henk
    old_body = forum_posts(:bewoners_forum_post_one).body
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_one).id, :forum_post => { :body => 'updated body' }
    assert_response :redirect
    assert_equal old_body, forum_posts(:bewoners_forum_post_one).reload.body
  end
  
  def test_should_destroy_forum_post_for_owner
    login_as :henk
    assert_difference('ForumPost.count', -1) do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    end
    assert_response :redirect
  end
  
  def test_should_destroy_forum_post_for_admin
    login_as :sjoerd
    assert_difference('ForumPost.count', -1) do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    end
    assert_response :redirect
  end
  
  def test_should_not_destroy_forum_post_for_non_owner
    login_as :gerjan
    assert_no_difference 'ForumPost.count' do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    end
    assert_response :redirect
  end
  
  def test_should_not_destroy_forum_post_for_non_user
    assert_no_difference 'ForumPost.count' do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_five).id
    end
    assert_response :redirect
  end
  
  def test_should_not_destroy_start_post
    login_as :henk
    assert_no_difference('ForumPost.count') do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :id => forum_posts(:bewoners_forum_post_one).id
    end
    assert_response :redirect
  end

  protected

    def create_forum_post(attributes = {}, options = {})
      post :create, { :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread_id => forum_threads(:bewoners_forum_thread_one).id, :forum_post => { :body => 'Some body' }.merge(attributes)}.merge(options)
    end
  
end
