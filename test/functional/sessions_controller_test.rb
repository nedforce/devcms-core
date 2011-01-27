require File.dirname(__FILE__) + '/../test_helper'

class SessionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_login_and_redirect
    post :create, :login => users(:gerjan).login, :password => 'gerjan'
    assert session[:user_id]
    assert_response :redirect
  end
  
  def test_new_should_redirect_if_already_logged_in
    login_as :sjoerd
    get :new
    assert_response :redirect
    assert flash.has_key?(:notice)
  end
  
  def test_create_should_redirect_if_already_logged_in
    login_as :sjoerd
    post :create, :login => users(:gerjan).login, :password => 'gerjan'
    assert_response :redirect
    assert flash.has_key?(:notice)
  end

  def test_should_login_case_insensitive_and_redirect
    post :create, :login => users(:gerjan).login.upcase, :password => 'gerjan'
    assert session[:user_id]
    assert_response :redirect
  end

  def test_should_fail_login
    post :create, :login => users(:gerjan).login, :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end
  
   def test_should_fail_login_if_not_verified
    post :create, :login => users(:unverified_user).login, :password => 'pass'
    assert_nil session[:user_id]
    assert assigns(:user), "No @user"
    assert_response :success
  end

  def test_should_logout
    login_as :gerjan
    delete :destroy
    assert_nil session[:user_id]
    assert_response :redirect
    assert flash.has_key?(:notice)
  end

  def test_should_show_confirmation_on_logout_with_get
    login_as :gerjan
    get :destroy
    assert_response :success
    assert_template 'confirm_destroy'
  end
    
  def test_should_not_logout_if_not_logged_in
    delete :destroy
    assert_response :redirect
    assert flash.has_key?(:warning)
  end
  
  def test_should_remember_me
    post :create, :login => users(:gerjan).login, :password => 'gerjan', :remember_me => '1'
    assert_not_nil @response.cookies['auth_token']
  end

  def test_should_not_remember_me
    post :create, :login => users(:gerjan).login, :password => 'gerjan', :remember_me => '0'
    assert_nil @response.cookies['auth_token']
  end
  
  def test_should_delete_token_on_logout
    login_as :gerjan
    delete :destroy
    assert_equal nil, @response.cookies['auth_token']
  end

  def test_should_login_with_cookie
    users(:gerjan).remember_me
    @request.cookies['auth_token'] = cookie_for(:gerjan)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    users(:gerjan).remember_me
    users(:gerjan).update_attribute :remember_token_expires_at, 5.minutes.ago.utc
    @request.cookies['auth_token'] = cookie_for(:gerjan)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:gerjan).remember_me
    @request.cookies['auth_token'] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end