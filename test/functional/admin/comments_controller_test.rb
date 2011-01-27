require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CommentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @comment = comments(:weblog_post_one_comment_one)
    @forum_start_post = forum_posts(:bewoners_forum_post_one)
    @forum_post = forum_posts(:bewoners_forum_post_five)
  end

  ## Comment tests
  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
    assert_equal false, assigns(:show_forum_posts)
  end

  def test_should_update_comment
    login_as :sjoerd

    put :update, :id => @comment, :format => 'json', :comment => { :comment => 'jaja' }

    assert_equal 'jaja', assigns(:comment).comment
    assert_response :success
  end

  def test_should_get_index_for_final_editor
    login_as :final_editor
    get :index
    assert_response :success
    assert assigns(:comments).empty?
  end

  def test_should_get_index_for_editor
    login_as :editor
    get :index
    assert_response :success
    assert assigns(:comments).empty?
  end

  def test_should_destroy_comment
    login_as :sjoerd

    assert_difference('Comment.count', -1) do
      delete :destroy, :id =>@comment, :format => 'json'
      assert_response :success
    end
  end

  ## ForumPost tests
  def test_should_get_index_with_forum_posts
    login_as :sjoerd
    get :index, :comment_type => 'forum_post'
    assert_response :success

    assert_equal true, assigns(:show_forum_posts)
    assert assigns(:comments).include?(@forum_post)
    assert !assigns(:comments).include?(@forum_start_post)
  end

  def test_should_update_forum_post
    login_as :sjoerd

    put :update, :comment_type => 'forum_post', :id => @forum_post, :format => 'json', :comment => { :comment => 'jaja' }

    assert_equal 'jaja', assigns(:comment).comment
    assert_response :success
  end

  def test_should_get_index_with_forum_posts_for_final_editor
    login_as :final_editor
    get :index, :comment_type => 'forum_post'
    assert_response :success
    assert assigns(:comments).empty?
  end

  def test_should_get_index_with_forum_posts_for_editor
    login_as :editor
    get :index, :comment_type => 'forum_post'
    assert_response :success
    assert assigns(:comments).empty?
  end

  def test_should_destroy_forum_post
    login_as :sjoerd

    assert_difference('ForumPost.count', -1) do
      delete :destroy, :comment_type => 'forum_post', :id =>@forum_post, :format => 'json'
      assert_response :success
    end
  end

  def test_should_not_destroy_forum_start_post
    login_as :sjoerd

    assert_no_difference('Comment.count') do
      delete :destroy, :comment_type => 'forum_post', :id =>@forum_start_post, :format => 'json'
      assert_response 422
    end
  end

  ## Authorization
  def test_should_require_roles
    assert_user_can_access :arthur, :index
    assert_user_can_access :arthur, :update, :id => @comment
    assert_user_can_access :arthur, :destroy, :id => @comment
    assert_user_can_access :final_editor, :index
    assert_user_can_access :final_editor, :update, :id => @comment
    assert_user_can_access :final_editor, :destroy, :id => @comment
    assert_user_can_access :editor, :index
    assert_user_can_access :editor, :update, :id => @comment
    assert_user_can_access :editor, :destroy, :id => @comment
  end

end

