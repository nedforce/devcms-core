require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::NewsletterSubscriptionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_newsletter_archive
    login_as :sjoerd

    get :list, :id => newsletter_archives(:devcms_newsletter_archive).id
    assert_response :success
    assert assigns(:newsletter_archive)
    assert assigns(:users)
  end

  def test_should_unsubscribe_user_from_newsletter_archive
    login_as :sjoerd

    delete :destroy, :newsletter_subscription_id => newsletter_archives(:example_newsletter_archive).id, :id => users(:arthur).id
    assert_response :success
    assert_equal 0, newsletter_archives(:example_newsletter_archive).users.count
  end

  def test_should_sort_for_extjs
    login_as :sjoerd
    post :list, :id => newsletter_archives(:devcms_newsletter_archive).id, :sort => 'user_login', :dir => 'DESC', :format => 'xml'
    assert_response :success
    assert_equal users(:sjoerd).email_address, assigns(:users).first.email_address
  end

  def test_should_sort_id_for_extjs
    login_as :sjoerd
    post :list, :id => newsletter_archives(:devcms_newsletter_archive).id, :sort => 'user_id', :dir => 'DESC', :format => 'xml'
    assert_response :success
    assert_equal newsletter_archives(:devcms_newsletter_archive).users.order(id: :desc).first.email_address, assigns(:users).first.email_address
  end

  def test_should_page_and_sort_for_extjs
    login_as :sjoerd
    post :list, :id => newsletter_archives(:devcms_newsletter_archive).id, :sort => 'user_email_address', :dir => 'DESC', :start => '0', :limit => '1', :format => 'xml'
    assert_response :success
    assert_equal 1, assigns(:users).size
    assert_equal users(:sjoerd).email_address, assigns(:users).first.email_address
  end
end
