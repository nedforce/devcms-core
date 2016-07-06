require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +User+ model.
class UserTest < ActiveSupport::TestCase
  test 'should create user' do
    assert_difference 'User.count' do
      user = create_user
      refute user.new_record?, user.errors.full_messages.to_sentence
    end
  end

  test 'should require login' do
    assert_no_difference 'User.count' do
      u = create_user(login: nil)
      assert u.errors[:login].any?

      u = create_user(login: '   ')
      assert u.errors[:login].any?
    end
  end

  test 'should require password' do
    assert_no_difference 'User.count' do
      u = create_user(password: nil)
      assert u.errors[:password].any?

      u = create_user(password: '   ')
      assert u.errors[:password].any?
    end
  end

  test 'should require password confirmation' do
    assert_no_difference 'User.count' do
      u = create_user(password_confirmation: nil)
      assert u.errors[:password_confirmation].any?
    end
  end

  test 'should require email address' do
    assert_no_difference 'User.count' do
      u = create_user(email_address: nil)
      assert u.errors[:email_address].any?
    end
  end

  test 'should require valid email address' do
    assert_no_difference 'User.count' do
      ['email@test,org', 'email@domain', 'a@a@domain.com', 'bla.,@bla.com', '@bla.com', '@', 'bla@bla.,org', 'foo@localhost'].each do |address|
        u = create_user(email_address: address)
        assert u.errors[:email_address].any?
      end
    end
  end

  test 'should require valid login' do
    u = create_user(login: 'A') # Too short
    assert u.errors[:login].any?

    u = create_user(login: 'A' * 256) # Too long
    assert u.errors[:login].any?

    u = create_user(login: 'no%crazy)stuff*allowed')
    assert u.errors[:login].any?

    u = create_user(login: 'numbers_123_underscores_and-dashes-are-OK')
    refute u.errors[:login].any?
  end

  test 'should not update login' do
    assert_raises ActiveRecord::ActiveRecordError do
      users(:sjoerd).update_attribute(:login, 'henk')
    end

    assert_equal 'sjoerd', users(:sjoerd).reload.login
  end

  test 'should not reset password if entropy is too low' do
    users(:gerjan).update_attributes(password: 'new password', password_confirmation: 'new password')
    assert_nil User.authenticate('gerjan', 'new password')
  end

  test 'should reset password' do
    users(:gerjan).update_attributes(password: 'new password 123', password_confirmation: 'new password 123')
    assert_equal users(:gerjan), User.authenticate('gerjan', 'new password 123')
  end

  test 'should not rehash password' do
    users(:gerjan).update_attributes(login: 'gerjan')
    assert_equal users(:gerjan), User.authenticate('gerjan', 'gerjan')
  end

  test 'should authenticate user' do
    assert_equal users(:gerjan), User.authenticate('gerjan', 'gerjan')
  end

  test 'should have role on root' do
    refute users(:final_editor).has_role_on?('admin')
    assert users(:arthur).has_role_on?('admin')
    refute users(:arthur).has_role_on?('editor')
  end

  test 'should have role on nodes' do
    assert users(:editor).has_role_on?('editor', nodes(:devcms_news_node))
    refute users(:editor).has_role_on?('editor', nodes(:contact_page_node))
    assert users(:editor).has_role_on?('editor', nodes(:devcms_news_item_node))
    assert users(:arthur).has_role_on?('admin',  nodes(:devcms_news_item_node))
  end

  test 'should have role with multiple roles on nodes' do
    assert users(:arthur).has_role_on?('final_editor', 'admin',  nodes(:economie_section_node))
    refute users(:arthur).has_role_on?('final_editor', 'editor', nodes(:economie_section_node))
    assert users(:editor).has_role_on?('final_editor', 'editor', nodes(:devcms_news_node))
    assert users(:final_editor).has_role_on?('final_editor', 'editor', nodes(:economie_section_node))
    refute users(:final_editor).has_role_on?(%w(final_editor editor admin), nodes(:devcms_news_node))
  end

  test 'should have role with multiple roles on root node' do
    assert users(:arthur).has_role_on?('final_editor', 'admin')
    refute users(:final_editor).has_role_on?(%w(final_editor editor))
  end

  test 'should have roles' do
    assert users(:arthur).has_role?('admin', 'editor', 'final-editor')
    refute users(:arthur).has_role?('editor', 'final-editor')
    refute users(:normal_user).has_role?(%w(admin editor final-editor))
  end

  test 'should have any role' do
    assert users(:arthur).has_any_role?
  end

  test 'should not have any role' do
    refute users(:normal_user).has_any_role?
  end

  test 'should return role on node' do
    assert_equal users(:arthur).role_on(nodes(:help_page_node)).name, 'admin'
    assert_equal users(:editor).role_on(nodes(:devcms_news_node)).name, 'editor'
    assert_nil users(:editor).role_on(nodes(:contact_page_node))
  end

  test 'should give role on node' do
    success = users(:editor).give_role_on('editor', nodes(:contact_page_node))
    assert success
    assert_equal 'editor', users(:editor).reload.role_on(nodes(:contact_page_node)).name
  end

  test 'should remove role from node' do
    users(:arthur).give_role_on('admin', Node.root)
    users(:arthur).remove_role_from(Node.root)
    refute users(:arthur).has_role?('admin')
  end

  test 'should not fail on remove of unexisting role' do
    users(:arthur).role_assignments.delete_all
    assert_nothing_raised do
      users(:arthur).remove_role_from(Node.root)
    end
  end

  test 'should demote and promote' do
    assert_equal 'PrivilegedUser', users(:arthur).type
    users(:arthur).demote!
    assert_equal 'User', users(:arthur).type
    assert_equal 'User', users(:klaas).type
    users(:klaas).promote!
    assert_equal 'PrivilegedUser', users(:klaas).type
  end

  test 'should lose privileged roles after demote' do
    users(:arthur).demote!
    refute User.find(users(:arthur).id).has_any_role?
  end

  test 'should keep non-privileged roles after demote' do
    assert users(:editor).give_role_on('read_access', Node.root)
    assert_difference('User.find(users(:editor).id).role_assignments.count', -6) do
      users(:editor).demote!
      refute User.find(users(:editor).id).role_assignments.any?(&:is_privileged?)
    end
  end

  test 'should have roles after demote' do
    users(:arthur).demote!
    refute User.find(users(:arthur).id).has_role?('admin', 'editor', 'final-editor')
  end

  test 'should return role on node after demote' do
    users(:arthur).demote!
    assert_nil User.find(users(:arthur).id).role_on(nodes(:help_page_node))
    assert_nil User.find(users(:arthur).id).role_on(nodes(:devcms_news_node))
  end

  test 'should strip sensitive information from xml' do
    xml = users(:arthur).to_xml
    User::SECRETS.each { |secret| refute xml.include?(secret.dasherize) }
  end

  test 'should keep sensitive information in secrets xml' do
    xml = users(:arthur).to_xml_with_secrets
    User::SECRETS.each { |secret| assert xml.include?(secret.dasherize) }
  end

  test 'should strip sensitive information from json' do
    json = users(:arthur).to_json
    User::SECRETS.each do |secret|
      refute json.include?(secret), "#{json.pretty_inspect} included #{secret}. It shouldn't"
    end
  end

  test 'should keep sensitive information in secrets json' do
    json = users(:arthur).to_json_with_secrets
    User::SECRETS.each { |secret| assert json.include?(secret), "#{json.pretty_inspect} didn't included #{secret}. It should" }
  end

  test 'has subscription for?' do
    newsletter_archives = NewsletterArchive.all

    User.all.each do |user|
      newsletter_archives.each do |newsletter_archive|
        if user.newsletter_archives.include?(newsletter_archive)
          assert user.has_subscription_for?(newsletter_archive)
        else
          refute user.has_subscription_for?(newsletter_archive)
        end
      end
    end
  end

  # Verification tests

  test 'verify should update user without code' do
    u = users(:unverified_user)
    u.verify!
    assert u.verified?
  end

  test 'should verify users verification code' do
    u = users(:unverified_user)
    u.update_attribute(:verification_code, '12345')
    assert u.verify_with('12345')
    assert u.verified?
  end

  test 'should not verify users verification code' do
    u = users(:unverified_user)
    u.update_attribute(:verification_code, '12345')
    refute u.verify_with('54321') # Invalid code
    refute u.verified?
  end

  test 'should generate valid verification code' do
    1000.times do # Generate 1000 codes to prevent coincidencial valid format.
      code = User.generate_verification_code_for(users(:sjoerd))
      assert code.is_a?(String)
      assert code =~ /\A[[:alnum:]]{5,}\z/, "'#{code}' is invalid."
    end
  end

  test 'should require verification code' do
    u = users(:sjoerd)
    u.verification_code = nil
    refute u.valid?
    assert u.errors[:verification_code].any?
  end

  test 'should auto set attrs on create' do
    u = create_user
    refute u.verified?
    assert u.verification_code.present?
  end

  test 'should reset verification code' do
    u = users(:sjoerd)
    prev_code = u.verification_code
    u.reset_verification_code
    assert_not_equal u.reload.verification_code, prev_code
  end

  test 'should generate password reset token' do
    u = users(:sjoerd)
    prev_token = u.password_reset_token
    u.create_password_reset_token
    assert_not_equal prev_token, u.reload.password_reset_token
  end

  test 'should get full name' do
    assert_equal 'Sjoerd Andringa', users(:sjoerd).full_name
  end

  test 'should not allow reserved logins' do
    Devcms.stubs(:reserved_logins_regex).returns(/(burger?meester|wethouder|gemeente|voorlichting)/i)
    %w(Burgemeester Wethouder Gemeente Voorlichting).each do |login|
      [login, login.downcase, login.upcase].each do |l|
        u = create_user(login: l)
        assert u.errors[:login].any?
      end
    end
  end

  test 'destruction of user should destroy associated weblogs' do
    henk = users(:henk)

    assert_difference 'Weblog.count', -1 * henk.weblogs.size do
      henk.destroy
    end
  end

  test 'destruction of user should destroy associated forum threads' do
    henk = users(:henk)

    assert_difference 'ForumThread.count', -1 * henk.forum_threads.size do
      henk.destroy
    end
  end

  test 'destruction of user should destroy associated forum posts' do
    assert_difference 'ForumPost.count', -1 * users(:normal_user).forum_posts.count do
      users(:normal_user).destroy
    end
  end

  test 'destruction of user should not destroy associated comments' do
    jan = users(:jan)

    assert jan.comments.count > 0
    assert_no_difference 'Comment.count' do
      jan.destroy
    end
  end

  test 'screen name should return full name if present else login' do
    u = create_user(login: 'corneel')
    assert_equal 'corneel', u.screen_name
    u = create_user(login: 'corneel', first_name: 'Cornelis', surname: 'van Kaperen')
    assert_equal 'Cornelis van Kaperen', u.screen_name
  end

  test 'to_param should return login' do
    assert_equal 'corneel', create_user(login: 'corneel').to_param
  end

  test 'should send invitation email' do
    ActionMailer::Base.deliveries.clear
    email_address = 'test@test.nl'
    User.send_invitation_email!(email_address)

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.first

    assert email.to.include?(email_address)
  end

  test 'should not verify invitation code for missing email address or code' do
    refute User.verify_invitation_code(nil, nil)
    refute User.verify_invitation_code(nil, ' ')
    refute User.verify_invitation_code(' ', nil)
    refute User.verify_invitation_code(' ', ' ')
    refute User.verify_invitation_code('test@test.nl', nil)
    refute User.verify_invitation_code('test@test.nl', ' ')
    refute User.verify_invitation_code(nil, 'test')
    refute User.verify_invitation_code(' ', 'test')
  end

  test 'should not verify invitation code for incorrect code' do
    refute User.verify_invitation_code('test@test.nl', 'bla')
  end

  test 'should verify invitation code for correct code' do
    email_address = 'test@test.nl'
    assert User.verify_invitation_code(email_address, User.send(:generate_invitation_code, email_address))
  end

  # An email notice is send if an email is already in use. This of course
  # should not be send when it is not in use.
  test 'should not send email notice if email address is not in use' do
    email_address = 'abc@example.com'

    ActionMailer::Base.deliveries.clear

    create_user(login: 'user_b', email_address: email_address)

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.first

    assert email.to.include?(email_address)
    refute email.body.include?(I18n.t('layouts.forgot_password'))
  end

  test 'should send email notice if email address is already in use' do
    email_address = 'test123@example.com'
    create_user(login: 'user_a', email_address: email_address)

    ActionMailer::Base.deliveries.clear

    create_user(login: 'user_b', email_address: email_address)

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.first
    assert email.to.include?(email_address)
    assert email.parts.first.body.include?('nieuw wachtwoord aanvragen')
  end

  test 'should ask for password renewal after a given period of time' do
    user = users(:gerjan)

    refute user.should_renew_password?
    assert user.update_column :renewed_password_at, (DevcmsCore.config.renew_password_after - 1.day).ago
    refute user.should_renew_password?
    assert user.update_column :renewed_password_at, (DevcmsCore.config.renew_password_after + 1.day).ago
    assert user.should_renew_password?
  end

  test 'should check that a renewed password differs from the original on renewal' do
    user = users(:gerjan)
    assert user.update_column :renewed_password_at, (DevcmsCore.config.renew_password_after + 1.day).ago

    refute user.update_attributes(password: 'gerjan', password_confirmation: 'gerjan')
    assert user.errors[:password].any?{|error| error =~ /mag niet hetzelfde zijn/ }
  end

  test 'should record password renew date' do
    user = users(:gerjan)
    assert user.update_attributes(password: 'new password 123', password_confirmation: 'new password 123')
    assert_equal Date.today, user.renewed_password_at.to_date
  end

  protected

  def create_user(options = {})
    User.create({
      login: 'paashaas',
      email_address: 'paas@haas.nl',
      password: 'pasen',
      password_confirmation: 'pasen'
    }.merge(options))
  end
end
