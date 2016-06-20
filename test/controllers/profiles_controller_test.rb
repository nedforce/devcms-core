require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +UsersController+.
class ProfilesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should not get show logged out' do
    get :show
    assert_response :redirect
  end

  test 'should get show' do
    login_as :sjoerd
    get :show

    assert_response :success
    assert_equal users(:sjoerd), assigns(:user)
    assert_select '#email_address'
    assert_select '[href=?]', "http://#{@request.host}/profile/edit"
    assert_select '.reg_form_fieldset'
  end

  test 'should show edit' do
    login_as :sjoerd
    get :edit

    assert_response :success
    assert_template 'edit'
  end

  test 'should update user' do
    login_as :sjoerd
    put :update, user: { first_name: 'Sjors' }

    assert_redirected_to profile_path
    assert flash[:notice].present?
    assert_equal 'Sjors', assigns(:user).first_name
  end

  test 'should not update user with invalid attr' do
    login_as :sjoerd
    put :update, user: { email_address: 'sjoerd@invalid' }, old_password: 'sjoerd'

    assert_response :unprocessable_entity
    assert assigns(:user).errors[:email_address].any?
  end

end
