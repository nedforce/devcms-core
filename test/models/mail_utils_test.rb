require File.expand_path('../../test_helper.rb', __FILE__)

class MailUtilsTest < ActiveSupport::TestCase
  test 'should escape display name in e-mail' do
    # Inject an extra recipient
    invalid_display_name = 'Jan <fake@test.com>", "'

    unescaped_email = bad_to_email('real@test.com', invalid_display_name)
    escaped_email = DevcmsCore::MailUtils.escape_email_address('real@test.com', invalid_display_name)

    # When unescaped we can successfully inject a recipient!
    mail = TestMailer.test_email(to: unescaped_email).deliver_now
    assert_equal 2, mail.to.size

    # Using the `escape_email_address` method this is no longer possible
    mail = TestMailer.test_email(to: escaped_email).deliver_now
    assert_equal 1, mail.to.size
    assert_equal 'real@test.com', mail.to.first
  end

  private

  # Emulate the behaviour of a bad to_email method
  def bad_to_email(email, display_name)
    "\"#{display_name}\" <#{email}>"
  end
end
