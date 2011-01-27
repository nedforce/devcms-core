require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_create_comments_for_user
    login_as :gerjan

    assert_difference('Comment.count', 2) do
      create_comment
      assert_response :redirect
      assert !assigns(:comment).new_record?, :message => assigns(:comment).errors.full_messages.join('; ')
      assert_equal users(:gerjan), assigns(:comment).user

      create_comment
      assert_response :redirect
      assert !assigns(:comment).new_record?, :message => assigns(:comment).errors.full_messages.join('; ')
      assert_equal users(:gerjan), assigns(:comment).user
    end
  end

  def test_should_not_create_comments_if_node_is_not_commentable
    login_as :gerjan

    assert_no_difference('Comment.count') do
      post :create, { :node_id => nodes(:devcms_news_item_voor_vorige_maand_node).id, :comment => { :comment => 'My comment' } }
      assert_response :redirect
    end
  end

  def test_should_create_comment_with_user_but_without_user_name
    login_as :gerjan

    assert_difference('Comment.count') do
      create_comment
      assert_equal users(:gerjan).login, assigns(:comment).user_name
    end
  end

  #  Support for commenting by unauthenticated users is present but has been disabled

  def test_should_not_create_comment_without_user_but_with_user_name
    assert_no_difference('Comment.count') do
      create_comment(:user_name => 'Jan')
      assert assigns(:comment).errors.on(:user)
    end
  end

#  def test_should_create_comment_without_user_but_with_user_name
#    assert_difference('Comment.count') do
#      create_comment(:user_name => 'Jan')
#      assert_equal 'Jan', assigns(:comment).user_name
#      assert assigns(:comment).valid?
#    end
#  end
#
#  def test_should_not_create_comment_without_user_and_user_name
#    assert_no_difference('Comment.count') do
#      create_comment
#      assert assigns(:comment).errors.on(:user_name)
#    end
#  end

  def test_should_destroy_comment
    login_as :arthur
    create_comment

    assert_difference('Comment.count', -1) do
      delete :destroy, :id => assigns(:comment).id
      assert_response :redirect
    end
  end

  def test_should_not_destroy_comment_without_login
    create_comment

    assert_no_difference('Comment.count') do
      delete :destroy, :id => assigns(:comment).id
      assert_response :not_found
    end
  end

  def test_should_render_confirmation_with_get
    login_as :gerjan
    create_comment

    assert_no_difference 'Comment.count' do
      get :destroy, :id => assigns(:comment).id
      assert_response :success
      assert_template 'confirm_destroy'
    end
  end

protected

  def create_comment(attributes = {}, options = {})
    post :create, { :node_id => nodes(:devcms_news_item_node).id, :comment => { :comment => 'My comment' }.merge(attributes)}.merge(options)
  end

end

