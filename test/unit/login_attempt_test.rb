require File.expand_path('../../test_helper.rb', __FILE__)

class LoginAttemptTest< ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
  end

  test 'should create login attempt' do
    assert_difference 'LoginAttempt.count' do
      login_attempt = create_login_attempt
      assert !login_attempt.new_record?, login_attempt.errors.full_messages.join("\n")
      assert !login_attempt.success?
    end
  end

  test 'should not create login attempt without ip' do
    assert_no_difference 'LoginAttempt.count' do
      create_login_attempt(:ip => nil)
    end
  end

  test 'should create successful login attempt' do
    assert_difference 'LoginAttempt.count' do
      login_attempt = create_login_attempt(:success => true)
      assert !login_attempt.new_record?, login_attempt.errors.full_messages.join("\n")
      assert login_attempt.success?
    end
  end

  test 'should create unsuccessful login attempt' do
    assert_difference 'LoginAttempt.count' do
      login_attempt = create_login_attempt(:success => false)
      assert !login_attempt.new_record?, login_attempt.errors.full_messages.join("\n")
      assert !login_attempt.success?
    end
  end

  test 'should return if last failed login attempt was less than ten seconds ago' do
    login_attempt = create_login_attempt(:success => false)
    assert LoginAttempt.last_attempt_was_not_ten_seconds_ago('123.45.67.80')
  end

  test 'should return if last successful login attempt was less than ten seconds ago' do
    login_attempt = create_login_attempt(:success => true)
    assert !LoginAttempt.last_attempt_was_not_ten_seconds_ago('123.45.67.80')

    login_attempt2 = create_login_attempt(:success => false)
    assert LoginAttempt.last_attempt_was_not_ten_seconds_ago('123.45.67.80')

    login_attempt3 = create_login_attempt(:success => true)
    assert LoginAttempt.last_attempt_was_not_ten_seconds_ago('123.45.67.80')
  end

  test 'should return if last failed login attempt was more than ten seconds ago' do
    login_attempt = login_attempts(:failed_login_attempt_11_seconds_ago)
    assert login_attempt
    assert !login_attempt.success?
    assert !LoginAttempt.last_attempt_was_not_ten_seconds_ago('11.11.11.11')
  end

  test 'should return if ip is not blocked' do
    login_attempt = create_login_attempt(:success => false)
    assert !LoginAttempt.is_ip_blocked?('123.45.67.80')

    9.times do
      create_login_attempt(:success => true)
    end
    assert !LoginAttempt.is_ip_blocked?('123.45.67.80')

    9.times do
      create_login_attempt(:success => false)
    end
    assert !LoginAttempt.is_ip_blocked?('123.45.67.80')

    create_login_attempt(:success => false)
    assert LoginAttempt.is_ip_blocked?('123.45.67.80')
  end

  test 'should return if ip is not blocked only for login attempts from the last 24 hours' do
    10.times do
      create_login_attempt(:success => false, :created_at => 2.days.ago)
    end
    assert !LoginAttempt.is_ip_blocked?('123.45.67.80')
  end

  protected

  def create_login_attempt(options = {})
    LoginAttempt.create({ :ip => '123.45.67.80', :user_login => users(:gerjan).login }.merge(options))
  end
end
