require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +UsersController+.
class UsersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should not get new for invalid invitation code or invitation email' do
    get :new
    assert_response :redirect

    get :new, invitation_email: 'test@test.nl', invitation_code: 'foo'
    assert_response :redirect
  end

  test 'should get new for valid invitation code and invitation email' do
    email = 'test@test.nl'
    get :new, invitation_email: email, invitation_code: User.send(:generate_invitation_code, email)

    assert_response :success
  end

  test 'should not create user for invalid invitation code or invitation email' do
    assert_no_difference('User.count') do
      create_user({}, invitation_email: nil, invitation_code: nil)
    end

    assert_response :redirect

    assert_no_difference('User.count') do
      create_user({}, invitation_email: 'test@test.nl', invitation_code: 'foo')
    end

    assert_response :redirect
  end

  test 'should create user for valid invitation code and invitation email' do
    assert_difference('User.count', 1) do
      create_user
    end

    assert_not_nil flash[:notice]
    assert_redirected_to login_path
  end

  test 'should send verification email on create' do
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      create_user
    end
  end

  test 'should not send verification email on create for invalid user data' do
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      create_user login: nil # if user was not saved
    end
  end

  test 'should subscribe to newsletter archives on create' do
    assert_difference('User.count', 1) do
      create_user(newsletter_archive_ids: [newsletter_archives(:devcms_newsletter_archive).id])
    end
    assert newsletter_archives(:devcms_newsletter_archive).users.include?(assigns(:user))
  end

  test 'should subscribe to interest on create' do
    assert_difference('User.count', 1) do
      create_user(interest_ids: [interests(:art_and_culture).id])
    end
    assert interests(:art_and_culture).users.include?(assigns(:user))
  end

  test 'should require login on create' do
    assert_no_difference 'User.count' do
      create_user(login: nil)
    end
    assert assigns(:user).errors[:login].any?
    assert_response :unprocessable_entity
  end

  test 'should require unique login on create' do
    assert_no_difference 'User.count' do
      create_user(login: users(:gerjan).login.upcase)
    end
    assert assigns(:user).errors[:login].any?
    assert_response :unprocessable_entity
  end

  test 'should require non-reserved login on create' do
    assert_no_difference 'User.count' do
      create_user(login: 'burgemeester')
    end
    assert assigns(:user).errors[:login].any?
    assert_response :unprocessable_entity
  end

  test 'should require password on create' do
    assert_no_difference 'User.count' do
      create_user(password: nil)
    end
    assert assigns(:user).errors[:password].any?
    assert_response :unprocessable_entity
  end

  test 'should require password confirmation on create' do
    assert_no_difference 'User.count' do
      create_user(password_confirmation: nil)
    end
    assert assigns(:user).errors[:password_confirmation].any?
    assert_response :unprocessable_entity
  end

  test 'should not create user with invalid login' do
    assert_no_difference('User.count') do
      create_user(login: 'invalid%login')
    end
    assert_response :unprocessable_entity
  end

  test 'should clear password fields on invalid create' do
    assert_no_difference 'User.count' do
      create_user(login: nil)
    end
    assert_nil assigns(:user).password
    assert_nil assigns(:user).password_confirmation
    assert_response :unprocessable_entity
  end

  test 'should verify user' do
    u = users(:unverified_user)
    get :verification, id: u.login, code: u.verification_code

    assert assigns(:user).verified, 'User not verified!'
    assert_response :redirect
    assert flash[:notice].present?, "Flash wasn't set."
  end

  test 'should not verify user on invalid code' do
    u = users(:unverified_user)
    get :verification, id: u.login, code: 'Some invalid code'

    refute assigns(:user).verified, 'User still verified!'
    assert_response :success
    assert_template 'verification_failed'
  end

  test 'should send verification email' do
    prev_code = users(:unverified_user).verification_code

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      get :send_verification_email, id: users(:unverified_user).login
    end
    assert_not_equal prev_code, assigns(:user).reload.verification_code
    assert_response :redirect
    assert flash[:notice].present?, "Flash wasn't set."
  end

  test 'should not send email if user has already been verified' do
    prev_code = users(:sjoerd).verification_code

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      get :send_verification_email, id: users(:sjoerd).login
    end
    assert_equal prev_code, assigns(:user).reload.verification_code
    assert_response :redirect
    assert flash[:warning].present?, "Flash wasn't set."
  end

  test 'should not register for spambots' do
    assert_no_difference 'User.count' do
      create_user(username: 'not-empty')
    end
  end

  protected

  def create_user(attributes = {}, options = {})
    invitation_email = options.key?(:invitation_email) ? options[:invitation_email] : 'test@test.nl'
    invitation_code  = options.key?(:invitation_code) ? options[:invitation_code] : User.send(:generate_invitation_code, invitation_email)

    post :create, {
      invitation_email: invitation_email,
      invitation_code: invitation_code,
      user: {
        first_name: 'Easter bunny',
        email_address: 'e.bunny@nedforce.nl',
        login: 'bunny',
        password: 'bunny',
        password_confirmation: 'bunny'
      }.merge(attributes)
    }
  end
end
