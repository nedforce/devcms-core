require File.expand_path('../../test_helper.rb', __FILE__)

class PasswordResetsControllerTest < ActionController::TestCase

  def test_should_get_new_password_reset
    get :new
    assert_response :success
  end

  def test_should_send_password_token_by_login
    old_hash = users(:sjoerd).password_reset_token
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_password_reset_by_login users(:sjoerd)
      assert_response :redirect
      assert_equal users(:sjoerd), assigns(:user)
      assert_not_equal old_hash, assigns(:user).reload.password_reset_token
      assert flash.key?(:notice)
    end
  end

  def test_should_send_password_token_by_email_address
    old_hash = users(:sjoerd).password_reset_token
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_password_reset_by_email_address users(:sjoerd)
      assert_response :redirect
      assert_equal users(:sjoerd), assigns(:user)
      assert_not_equal old_hash, assigns(:user).reload.password_reset_token
      assert flash.key?(:notice)
    end
  end

  def test_should_not_send_reminder_mail_by_invalid_input
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :create, :login_email => 'Ch|_|ckn0rr15'
      assert_response :redirect
      assert_nil assigns(:user)
      assert flash.key?(:notice)
    end
  end

  def test_should_get_edit_password_reset
    create_password_reset_by_login users(:sjoerd)
    get :edit, :id => assigns(:user).password_reset_token
    assert_response :success
    assert_equal assigns(:user), users(:sjoerd)
  end

  def test_should_set_new_password
    create_password_reset_by_login users(:sjoerd)
    put :update, :id => assigns(:user).password_reset_token, :user => { :password => 'Ch|_|ckn0rr15', :password_confirmation => 'Ch|_|ckn0rr15' }
    assert_response :redirect
    assert_nil assigns(:user).password_reset_token
    assert flash.key?(:notice)
  end

  def test_should_confirm_new_password
    create_password_reset_by_login users(:sjoerd)
    put :update, :id => assigns(:user).password_reset_token, :user => { :password => 'Ch|_|ckn0rr15', :password_confirmation => 'Ch|_|ckn0rr16' }
    assert_response :success
    assert assigns(:user).errors[:password].any?
  end

  def test_should_not_accept_expired_password_reset
    create_password_reset_by_login users(:sjoerd)
    old_hash = assigns(:user).password_reset_token
    assigns(:user).update_attribute :password_reset_expiration, 1.day.ago
    put :update, :id => assigns(:user).password_reset_token, :user => { :password => 'Ch|_|ckn0rr15', :password_confirmation => 'Ch|_|ckn0rr15' }
    assert_response :redirect
    assert_equal old_hash, assigns(:user).reload.password_reset_token
    assert flash.key?(:notice)
  end

  protected

  def create_password_reset_by_login(user)
    post :create, :login_email => user.login
  end

  def create_password_reset_by_email_address(user)
    post :create, :login_email => user.email_address
  end
end
