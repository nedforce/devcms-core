require File.dirname(__FILE__) + '/../test_helper'

class ForumThreadsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_forum_thread
    get :show, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :success
    assert assigns(:forum_thread)
  end

  def test_should_show_forum_thread_atom
    get :show, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id, :format => 'atom'
    assert_response :success
  end

  def test_should_get_new_for_user
    login_as :gerjan
    get :new, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id
    assert assigns(:forum_thread)
    assert_response :success
  end

  def test_should_not_get_new_for_non_user
    get :new, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id
    assert_response :redirect
  end

  def test_should_create_forum_thread_for_user
    login_as :gerjan
    assert_difference('ForumThread.count', 1) do
      assert_difference('ForumPost.count', 1) do
        create_forum_thread
        assert !assigns(:forum_thread).new_record?, :message => assigns(:forum_thread).errors.full_messages.join('; ')
        assert !assigns(:start_post).new_record?, :message => assigns(:start_post).errors.full_messages.join('; ')
        assert_equal users(:gerjan), assigns(:forum_thread).user
        assert_equal users(:gerjan), assigns(:start_post).user
        assert_response :redirect
      end
    end
  end

  def test_should_not_create_forum_thread_with_invalid_topic_title
    login_as :gerjan
    assert_no_difference('ForumThread.count') do
      assert_no_difference('ForumPost.count') do
        create_forum_thread(:title => nil)
        assert_response :success
        assert assigns(:forum_thread).errors.on(:title)
      end
    end
  end

  def test_should_not_create_forum_thread_with_invalid_post_body
    login_as :gerjan
    assert_no_difference('ForumThread.count') do
      assert_no_difference('ForumPost.count') do
        create_forum_thread({}, { :body => nil })
        assert_response :success
        assert assigns(:start_post).new_record?
        assert assigns(:start_post).errors.on(:body)
      end
    end
  end

  def test_should_not_create_forum_thread_for_non_user
    assert_no_difference('ForumThread.count') do
      assert_no_difference('ForumPost.count') do
        create_forum_thread()
        assert_response :redirect
      end
    end
  end

  def test_should_get_edit_for_owner
    login_as :henk
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :success
    assert assigns(:forum_thread)
  end

  def test_should_get_edit_for_admin
    login_as :sjoerd
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :success
    assert assigns(:forum_thread)
  end

  def test_should_not_get_edit_for_non_owner
    login_as :gerjan
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :redirect
  end

  def test_should_not_get_edit_for_non_user
    get :edit, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :redirect
   end

  def test_should_update_forum_thread_for_owner
    login_as :henk
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id, :forum_thread => { :title => 'updated title' }, :start_post => { :body => 'foo_bar' }
    assert_response :redirect
    assert_equal 'updated title', assigns(:forum_thread).title
  end

  def test_should_update_forum_thread_for_admin
    login_as :sjoerd
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id, :forum_thread => { :title => 'updated title' }, :start_post => { :body => 'foo_bar' }
    assert_response :redirect
    assert_equal 'updated title', assigns(:forum_thread).title
  end

  def test_should_not_update_forum_thread_with_invalid_title
    login_as :henk
    old_title = forum_threads(:bewoners_forum_thread_one).title
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id, :forum_thread => { :title => nil }
    assert_response :success
    assert assigns(:forum_thread).errors.on(:title)
    assert_equal old_title, forum_threads(:bewoners_forum_thread_one).reload.title
  end

  def test_should_not_update_forum_thread_for_non_owner
    login_as :gerjan
    old_title = forum_threads(:bewoners_forum_thread_one).title
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id, :forum_thread => { :title => 'updated title' }
    assert_response :redirect
    assert_equal old_title, forum_threads(:bewoners_forum_thread_one).reload.title
  end

  def test_should_not_update_forum_thread_for_non_user
    old_title = forum_threads(:bewoners_forum_thread_one).title
    put :update, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id, :forum_thread => { :title => 'updated title' }
    assert_response :redirect
    assert_equal old_title, forum_threads(:bewoners_forum_thread_one).reload.title
  end

  def test_should_destroy_forum_thread_for_owner
    login_as :henk
    assert_difference('ForumThread.count', -1) do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    end
    assert_response :redirect
  end

  def test_should_destroy_forum_thread_for_admin
    login_as :sjoerd
    assert_difference('ForumThread.count', -1) do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    end
    assert_response :redirect
  end

  def test_should_not_destroy_forum_thread_for_non_owner
    login_as :gerjan
    assert_no_difference 'ForumThread.count' do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    end
    assert_response :redirect
  end

  def test_should_not_destroy_forum_thread_for_non_user
    assert_no_difference 'ForumThread.count' do
      delete :destroy, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    end
    assert_response :redirect
  end

  def test_should_close_open_thread_for_admin
    login_as :sjoerd
    put :close, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert assigns(:forum_thread).closed?
    assert_response :redirect
  end

  def test_should_not_close_open_thread_for_non_admin
    login_as :gerjan
    put :close, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert !forum_threads(:bewoners_forum_thread_one).closed?
    assert_response :redirect
  end

  def test_should_not_close_open_thread_for_non_user
    put :close, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert !forum_threads(:bewoners_forum_thread_one).closed?
    assert_response :redirect
  end

  def test_should_not_close_closed_thread
    forum_threads(:bewoners_forum_thread_one).close
    login_as :sjoerd
    put :close, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert assigns(:forum_thread).closed?
    assert_not_nil flash[:warning]
    assert_response :redirect
  end

  def test_should_open_closed_thread_for_admin
    forum_threads(:bewoners_forum_thread_one).close
    login_as :sjoerd
    put :open, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert !assigns(:forum_thread).closed?
    assert_response :redirect
  end

  def test_should_not_open_closed_thread_for_non_admin
    forum_threads(:bewoners_forum_thread_one).close
    login_as :gerjan
    put :open, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert forum_threads(:bewoners_forum_thread_one).closed?
    assert_response :redirect
  end

  def test_should_not_open_closed_thread_for_non_user
    forum_threads(:bewoners_forum_thread_one).close
    put :open, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert forum_threads(:bewoners_forum_thread_one).closed?
    assert_response :redirect
  end

  def test_should_not_open_open_thread
    login_as :sjoerd
    put :open, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert !assigns(:forum_thread).closed?
    assert_not_nil flash[:warning]
    assert_response :redirect
  end

  def test_should_render_404_for_forum_thread_with_no_posts
    ForumPost.delete_all
    assert_nil forum_threads(:bewoners_forum_thread_one).forum_posts.first
    get :show, :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :id => forum_threads(:bewoners_forum_thread_one).id
    assert_response :not_found
  end
  
  protected

    def create_forum_thread(topic_attributes = {}, post_attributes = {}, options = {})
      post :create, { :forum_topic_id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_thread => { :title => 'Some title.' }.merge(topic_attributes), :start_post => { :body => 'blaatje' }.merge(post_attributes)}.merge(options)
    end
  
end
