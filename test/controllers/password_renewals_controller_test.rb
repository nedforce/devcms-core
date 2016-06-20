require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +PasswordResetsController+.
class PasswordRenewalsControllerTest < ActionController::TestCase
  setup do
    @user = users(:sjoerd)
    login_as :sjoerd
  end

  test 'should get password renewal' do
    get :edit
    assert_response :success
  end

  test 'should set new password' do
    auth_token = @user.auth_token

    put :update, user: { password: 'Ch|_|ckn0rr15', password_confirmation: 'Ch|_|ckn0rr15' }

    assert_response :redirect
    assert_not_equal auth_token, @user.reload.auth_token
    assert flash[:notice].present?
  end

end
