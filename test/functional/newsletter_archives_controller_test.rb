require File.dirname(__FILE__) + '/../test_helper'

class NewsletterArchivesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_show_newsletter_archive
    get :show, :id => newsletter_archives(:devcms_newsletter_archive).id
    assert_response :success
    assert assigns(:newsletter_archive)
    assert assigns(:latest_newsletter_editions)
    assert assigns(:newsletter_editions_for_table)
    assert_equal nodes(:newsletter_archive_node), assigns(:node)
  end
  
  def test_should_subscribe_to_news_archive_for_user
    login_as :gerjan
    
    assert_difference('newsletter_archives(:devcms_newsletter_archive).users.count', 1) do
      post :subscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_redirected_to newsletter_archive_path(newsletter_archives(:devcms_newsletter_archive))
    end
  end
  
  def test_should_not_subscribe_to_news_archive_if_already_subscribed
    login_as :sjoerd
    
    assert_no_difference('newsletter_archives(:devcms_newsletter_archive).users.count') do
      post :subscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_redirected_to newsletter_archive_path(newsletter_archives(:devcms_newsletter_archive))
    end
  end
  
  def test_should_not_subscribe_to_news_archive_for_non_user
    assert_no_difference('newsletter_archives(:devcms_newsletter_archive).users.count') do
      post :subscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_response :redirect
    end
  end
  
  def test_should_unsubscribe_from_news_archive_for_user
    login_as :sjoerd
    
    assert_difference('newsletter_archives(:devcms_newsletter_archive).users.count', -1) do
      delete :unsubscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_redirected_to newsletter_archive_path(newsletter_archives(:devcms_newsletter_archive))
    end
  end
  
  def test_should_show_confirmation_on_unsubscribe_with_get
    login_as :sjoerd
    
    assert_no_difference('newsletter_archives(:devcms_newsletter_archive).users.count') do
      get :unsubscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_response :success
      assert_template 'confirm_destroy'
    end
  end
  
  def test_should_not_unsubscribe_from_news_archive_if_not_subscribed
    login_as :gerjan
    
    assert_no_difference('newsletter_archives(:devcms_newsletter_archive).users.count') do
      delete :unsubscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_redirected_to newsletter_archive_path(newsletter_archives(:devcms_newsletter_archive))
    end
  end
  
  def test_should_not_unsubscribe_from_news_archive_for_non_user
    assert_no_difference('newsletter_archives(:devcms_newsletter_archive).users.count') do
      delete :unsubscribe, :id => newsletter_archives(:devcms_newsletter_archive).id
      assert_response :redirect
    end
  end
  
  def test_should_not_show_unpublished_newsletter_editions
    get :show, :id => newsletter_archives(:example_newsletter_archive).id
    assert_equal 0, assigns(:newsletter_editions).size
  end
  
end
