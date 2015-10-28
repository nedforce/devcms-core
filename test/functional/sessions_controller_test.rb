require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +SessionsController+.
class SessionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should login and redirect' do
    post :create, login: users(:gerjan).login, password: 'gerjan'

    assert_equal cookies[:auth_token], users(:gerjan).auth_token
    assert_response :redirect
  end

  test 'new should redirect if already logged in' do
    login_as :sjoerd
    get :new

    assert_response :redirect
    assert flash.key?(:notice)
  end

  test 'create should redirect if already logged in' do
    login_as :sjoerd
    post :create, login: users(:gerjan).login, password: 'gerjan'

    assert_response :redirect
    assert flash.key?(:notice)
  end

  test 'should login case insensitive and redirect' do
    post :create, login: users(:gerjan).login.upcase, password: 'gerjan'

    assert_equal cookies[:auth_token], users(:gerjan).auth_token
    assert_response :redirect
  end

  test 'should fail login' do
    post :create, login: users(:gerjan).login, password: 'bad password'

    assert_nil cookies[:auth_token]
    assert_response :unprocessable_entity
  end

  test 'should fail login if not verified' do
    post :create, login: users(:unverified_user).login, password: 'pass'

    assert_nil cookies[:auth_token]
    assert assigns(:user), 'No @user'
    assert_response :unprocessable_entity
  end

  test 'should logout' do
    login_as :gerjan
    delete :destroy

    assert_nil cookies[:auth_token]
    assert_response :redirect
    assert flash.key?(:notice)
  end

  test 'should show confirmation on logout with GET' do
    login_as :gerjan
    get :destroy

    assert_response :success
    assert_template 'confirm_destroy'
  end

  test 'should not logout if not logged in' do
    delete :destroy

    assert_response :redirect
    assert flash.key?(:warning)
  end

  test 'should reset auth token on logout' do
    auth_token = users(:gerjan).auth_token
    login_as :gerjan
    delete :destroy

    assert_not_equal auth_token, users(:gerjan).reload.auth_token
    assert_nil @response.cookies['auth_token']
  end

  test 'should login with valid auth token' do
    @request.cookies['auth_token'] = users(:gerjan).auth_token
    get :new

    assert @controller.send(:logged_in?), "Should be logged in, but wasn't.."
  end

  test 'should fail login with invalid auth token' do
    @request.cookies['auth_token'] = 'invalid_auth_token'
    get :new

    assert !@controller.send(:logged_in?)
  end

  test 'invalid csrf token' do
    with_csrf_check_enabled do
      post :create, login: users(:gerjan).login.upcase, password: 'gerjan', authenticity_token: 'wrong_token'
      assert_response :unprocessable_entity
    end
  end
end
