require File.expand_path('../../test_helper.rb', __FILE__)

class UsersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_not_get_show_logged_out
    get :show, :id => users(:sjoerd).login

    assert_response :redirect
  end

  def test_should_not_get_show_logged_in_as_different_user
    login_as :arthur
    get :show, :id => users(:sjoerd).login

    assert_response :not_found
  end

  test 'should get show logged in as owner' do
    login_as :sjoerd
    get :show, :id => users(:sjoerd).login

    assert_response :success
    assert_equal users(:sjoerd), assigns(:user)
    assert_select '#email_address'
    assert_select '[href=?]', "http://#{@request.host}/users/#{users(:sjoerd).login}/edit"
    assert_select '.reg_form_additional_info_header'
  end

  test 'should get profile logged in as owner' do
    login_as :sjoerd
    get :profile

    assert_response :success
    assert_equal users(:sjoerd), assigns(:user)
    assert_select '#email_address'
    assert_select '[href=?]', "http://#{@request.host}/users/#{users(:sjoerd).login}/edit"
    assert_select '.reg_form_additional_info_header'
  end

  def test_should_not_get_new_for_invalid_invitation_code_or_invitation_email
    get :new
    assert_response :redirect

    get :new, :invitation_email => 'test@test.nl', :invitation_code => 'foo'
    assert_response :redirect
  end

  def test_should_get_new_for_valid_invitation_code_and_invitation_email
    email = 'test@test.nl'
    get :new, :invitation_email => email, :invitation_code => User.send(:generate_invitation_code, email)

    assert_response :success
  end

  def test_should_not_create_user_for_invalid_invitation_code_or_invitation_email
    assert_no_difference('User.count') do
      create_user({}, { :invitation_email => nil, :invitation_code => nil })
    end

    assert_response :redirect

    assert_no_difference('User.count') do
      create_user({}, { :invitation_email => 'test@test.nl', :invitation_code => 'foo' })
    end

    assert_response :redirect
  end

  def test_should_create_user_for_valid_invitation_code_and_invitation_email
    assert_difference('User.count', 1) do
      create_user
    end

    assert_not_nil flash[:notice]
    assert_redirected_to login_path
  end

  def test_should_send_verification_email_on_create
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_user
    end
  end

  def test_should_not_send_verification_email_on_create_for_invalid_user_data
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      create_user :login => nil # if user was not saved
    end
  end

  def test_should_subscribe_to_newsletter_archives_on_create
    assert_difference('User.count', 1) do
      create_user(:newsletter_archive_ids => [ newsletter_archives(:devcms_newsletter_archive).id ])
    end
    assert newsletter_archives(:devcms_newsletter_archive).users.include?(assigns(:user))
  end

  def test_should_subscribe_to_interest_on_create
    assert_difference('User.count', 1) do
      create_user(:interest_ids => [ interests(:art_and_culture).id ])
    end
    assert interests(:art_and_culture).users.include?(assigns(:user))
  end

  def test_should_require_login_on_create
    assert_no_difference 'User.count' do
      create_user(:login => nil)
    end
    assert assigns(:user).errors[:login].any?
    assert_response :unprocessable_entity
  end
  
  def test_should_require_unique_login_on_create
    assert_no_difference 'User.count' do
      create_user(:login => users(:gerjan).login.upcase)
    end
    assert assigns(:user).errors[:login].any?
    assert_response :unprocessable_entity
  end
  
  def test_should_require_non_reserved_login_on_create
    assert_no_difference 'User.count' do
      create_user(:login => 'burgemeester')
    end
    assert assigns(:user).errors[:login].any?
    assert_response :unprocessable_entity
  end
  
  def test_should_require_password_on_create
    assert_no_difference 'User.count' do
      create_user(:password => nil)
    end
    assert assigns(:user).errors[:password].any?
    assert_response :unprocessable_entity
  end

  def test_should_require_password_confirmation_on_create
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
    end
    assert assigns(:user).errors[:password_confirmation].any?
    assert_response :unprocessable_entity
  end

  def test_should_not_create_user_with_invalid_login
    assert_no_difference('User.count') do
      create_user(:login => 'invalid%login')
    end
    assert_response :unprocessable_entity
  end

  def test_should_clear_password_fields_on_invalid_create
    assert_no_difference 'User.count' do
      create_user(:login => nil)
    end
    assert_nil assigns(:user).password
    assert_nil assigns(:user).password_confirmation
    assert_response :unprocessable_entity
  end

  def test_should_show_edit
    login_as :sjoerd
    get :edit, :id => users(:sjoerd).login

    assert_response :success
    assert_template 'edit'
  end

  def test_should_require_login_for_edit
    get :edit, :id => users(:sjoerd).login
    assert_response :redirect
  end

  def test_should_require_owner_on_edit
    login_as :arthur
    get :edit, :id => users(:sjoerd).login
    assert_response :not_found
  end

  def test_should_update_user
    login_as :sjoerd
    put :update, :id => users(:sjoerd).login, :user => { :first_name => 'Sjors' }

    assert_redirected_to user_path(users(:sjoerd))
    assert flash.key?(:notice)
    assert_equal 'Sjors', assigns(:user).first_name
  end

  def test_should_not_update_user_with_invalid_attr
    login_as :sjoerd
    put :update, :id => users(:sjoerd).login, :user => { :email_address => 'sjoerd@invalid' }, :old_password => 'sjoerd'

    assert_response :unprocessable_entity
    assert assigns(:user).errors[:email_address].any?
  end

  def test_update_should_require_login
    put :update, :id => users(:sjoerd).login, :user => { :email_address => 'sjoerd@nedforce.nl' }

    assert_response :redirect
    assert flash.key?(:warning)
  end

  def test_update_should_require_owner
    login_as :arthur
    put :update, :id => users(:sjoerd).login, :user => { :email_address => 'sjoerd@nedforce.nl' }

    assert_response :not_found
  end

  def test_should_verify_user
    u = users(:unverified_user)
    get :verification, :id => u.login, :code => u.verification_code
    assert assigns(:user).verified, 'User not verified!'
    assert_response :redirect
    assert flash.key?(:notice), "Flash wasn't set."
  end

  def test_should_not_verify_user_on_invalid_code
    u = users(:unverified_user)
    get :verification, :id => u.login, :code => 'Some invalid code'

    assert !assigns(:user).verified, 'User still verified!'
    assert_response :success
    assert_template 'verification_failed'
  end

  def test_should_send_verification_email
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      prev_code = users(:unverified_user).verification_code
      get :send_verification_email, :id => users(:unverified_user).login

      assert_not_equal prev_code, assigns(:user).reload.verification_code
      assert_response :redirect
      assert flash.key?(:notice), "Flash wasn't set."
    end
  end

  def test_should_not_send_email_if_user_has_already_been_verified
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      prev_code = users(:sjoerd).verification_code
      get :send_verification_email, :id => users(:sjoerd).login

      assert_equal prev_code, assigns(:user).reload.verification_code
      assert_response :redirect
      assert flash.key?(:warning), "Flash wasn't set."
    end
  end

  def test_should_not_register_for_spambots
    assert_no_difference 'User.count' do
      create_user(:username => 'not-empty')
    end
  end

  protected

  def create_user(attributes = {}, options = {})
    invitation_email = options.key?(:invitation_email) ? options[:invitation_email] : 'test@test.nl'
    invitation_code  = options.key?(:invitation_code)  ? options[:invitation_code]  : User.send(:generate_invitation_code, invitation_email)

    post :create, {
      :invitation_email => invitation_email,
      :invitation_code => invitation_code,
      :user => { :first_name => 'Easter bunny', :email_address => 'e.bunny@nedforce.nl', :login => 'bunny', :password => 'bunny', :password_confirmation => 'bunny' }.merge(attributes)
    }
  end
end
