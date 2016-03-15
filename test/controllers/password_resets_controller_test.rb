require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +PasswordResetsController+.
class PasswordResetsControllerTest < ActionController::TestCase
  test 'should get new password reset' do
    get :new
    assert_response :success
  end

  test 'should send password token by login' do
    old_hash = users(:sjoerd).password_reset_token
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_password_reset_by_login users(:sjoerd)
      assert_response :redirect
      assert_equal users(:sjoerd), assigns(:user)
      assert_not_equal old_hash, assigns(:user).reload.password_reset_token
      assert flash[:notice].present?
    end
  end

  test 'should send password token by email address' do
    old_hash = users(:sjoerd).password_reset_token
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_password_reset_by_email_address users(:sjoerd)
      assert_response :redirect
      assert_equal users(:sjoerd), assigns(:user)
      assert_not_equal old_hash, assigns(:user).reload.password_reset_token
      assert flash[:notice].present?
    end
  end

  test 'should not send reminder mail by invalid input' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :create, login_email: 'Ch|_|ckn0rr15'
      assert_response :redirect
      assert_nil assigns(:user)
      assert flash[:notice].present?
    end
  end

  test 'should get edit password reset' do
    create_password_reset_by_login users(:sjoerd)
    get :edit, id: assigns(:user).password_reset_token
    assert_response :success
    assert_equal assigns(:user), users(:sjoerd)
  end

  test 'should set new password' do
    auth_token = users(:sjoerd).auth_token
    create_password_reset_by_login users(:sjoerd)
    put :update, id: assigns(:user).password_reset_token, user: { password: 'Ch|_|ckn0rr15', password_confirmation: 'Ch|_|ckn0rr15' }

    assert_response :redirect
    assert_nil assigns(:user).password_reset_token
    assert_not_equal auth_token, users(:sjoerd).reload.auth_token
    assert flash[:notice].present?
  end

  test 'should confirm new password' do
    create_password_reset_by_login users(:sjoerd)
    put :update, id: assigns(:user).password_reset_token, user: { password: 'Ch|_|ckn0rr15', password_confirmation: 'wrongpass' }
    assert_response :success
    assert assigns(:user).errors[:password_confirmation].any? # Should be :password? Possibly a Rails 4.0 bug
  end

  test 'should not accept expired password reset' do
    create_password_reset_by_login users(:sjoerd)
    old_hash = assigns(:user).password_reset_token
    assigns(:user).update_attribute :password_reset_expiration, 1.day.ago
    put :update, id: assigns(:user).password_reset_token, user: { password: 'Ch|_|ckn0rr15', password_confirmation: 'Ch|_|ckn0rr15' }
    assert_response :redirect
    assert_equal old_hash, assigns(:user).reload.password_reset_token
    assert flash[:notice].present?
  end

  protected

  def create_password_reset_by_login(user)
    post :create, login_email: user.login
  end

  def create_password_reset_by_email_address(user)
    post :create, login_email: user.email_address
  end
end
