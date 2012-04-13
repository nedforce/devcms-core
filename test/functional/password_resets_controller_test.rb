require File.dirname(__FILE__) + '/../test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  
  def test_should_get_new_password_reset
    get :new
    assert_response :success
  end
  
  def test_should_send_password_token_by_login
    old_hash = users(:sjoerd).password_reset_token
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_password_reset users(:sjoerd)
      assert_response :redirect
      assert_equal users(:sjoerd), assigns(:user)
      assert_not_equal old_hash, assigns(:user).reload.password_reset_token
      assert flash.has_key?(:notice)
    end
  end
  
  def test_should_send_password_token_by_email
    old_hash = users(:sjoerd).password_reset_token, :email
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_password_reset users(:sjoerd)
      assert_response :redirect
      assert_equal users(:sjoerd), assigns(:user)
      assert_not_equal old_hash, assigns(:user).reload.password_reset_token
      assert flash.has_key?(:notice)
    end
  end
  
  def test_should_send_reminder_mail_by_invalid_input
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      post :create, :login_email => 'Ch|_|ckn0rr15'
      assert_response :redirect
      assert_equal assigns(:user), nil
      assert flash.has_key?(:notice)
    end
  end
  
  def test_should_get_edit_password_reset
    create_password_reset users(:sjoerd)
    get :edit, :id => assigns(:user).password_reset_token
    assert_response :success
    assert_equal assigns(:user), users(:sjoerd)
  end
  
  def test_should_set_new_password
    create_password_reset users(:sjoerd)
    put :update, :id => assigns(:user).password_reset_token, :user => { :password => 'test', :password_confirmation => 'test' }
    assert_response :redirect
    assert_equal assigns(:user).password_reset_token, nil
    assert flash.has_key?(:notice)
  end
  
  def test_should_confirm_new_password
    create_password_reset users(:sjoerd)
    put :update, :id => assigns(:user).password_reset_token, :user => { :password => 'test', :password_confirmation => 'test2' }
    assert_response :success
    assert assigns(:user).errors.on(:password)
  end
  
  def test_should_not_accept_expired_password_reset
    create_password_reset users(:sjoerd)
    old_hash = assigns(:user).password_reset_token
    assigns(:user).update_attribute :password_reset_expiration, Time.now - 1.day
    put :update, :id => assigns(:user).password_reset_token, :user => { :password => 'test', :password_confirmation => 'test' }
    assert_response :redirect
    assert_equal old_hash, assigns(:user).reload.password_reset_token
    assert flash.has_key?(:notice)
  end
  
  protected
  
    def create_password_reset(user, by_attr = :login)
      if by_attr == :email
        post :create, :login_email => user.email
      else
        post :create, :login_email => user.login
      end
    end
  
end
