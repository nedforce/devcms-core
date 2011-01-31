require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end

    assert_no_difference 'User.count' do
      u = create_user(:login => "   ")
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end

    assert_no_difference 'User.count' do
      u = create_user(:password => "   ")
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email_address
    assert_no_difference 'User.count' do
      u = create_user(:email_address => nil)
      assert u.errors.on(:email_address)
    end
  end

  def test_should_require_valid_email_address
    assert_no_difference 'User.count' do
      ["email@test,org", "email@domain", "a@a@domain.com", "bla.,@bla.com", "@bla.com", "@", "bla@bla.,org", "foo@localhost"].each do |address|
        u = create_user(:email_address => address)
        assert u.errors.on(:email_address)
      end
    end
  end

  def test_should_require_valid_login
    u = create_user(:login => "A") # TOO SHORT
    assert u.errors.on(:login)

# => Bug in DB2 adapter: Throws a StatementInvalid exception on validation.
#    u = create_user(:login => "A"*256) # TOO LONG
#    assert u.errors.on(:login)

    u = create_user(:login => "no%crazy)stuff*allowed")
    assert u.errors.on(:login)

    u = create_user(:login => "numbers_123_underscores_and-dashes-are-OK")
    assert !u.errors.on(:login)
  end

  def test_should_not_update_login
    users(:sjoerd).update_attribute(:login, "henk")
    assert_equal "sjoerd", users(:sjoerd).reload.login
  end

  def test_should_reset_password
    users(:gerjan).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:gerjan), User.authenticate('gerjan', 'new password')
  end

  def test_should_not_rehash_password
    users(:gerjan).update_attributes(:login => 'gerjan')
    assert_equal users(:gerjan), User.authenticate('gerjan', 'gerjan')
  end

  def test_should_authenticate_user
    assert_equal users(:gerjan), User.authenticate('gerjan', 'gerjan')
  end

  def test_should_set_remember_token
    users(:gerjan).remember_me
    assert_not_nil users(:gerjan).remember_token
    assert_not_nil users(:gerjan).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:gerjan).remember_me
    assert_not_nil users(:gerjan).remember_token
    users(:gerjan).forget_me
    assert_nil users(:gerjan).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:gerjan).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:gerjan).remember_token
    assert_not_nil users(:gerjan).remember_token_expires_at
    assert users(:gerjan).remember_token?
    assert users(:gerjan).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:gerjan).remember_me_until time
    assert_not_nil users(:gerjan).remember_token
    assert_not_nil users(:gerjan).remember_token_expires_at
    assert_equal users(:gerjan).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:gerjan).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:gerjan).remember_token
    assert_not_nil users(:gerjan).remember_token_expires_at
    assert users(:gerjan).remember_token_expires_at.between?(before, after)
  end

  def test_should_have_role_on_root
    assert !users(:final_editor).has_role_on?("admin")
    assert users(:arthur).has_role_on?("admin")
    assert !users(:arthur).has_role_on?("editor")
  end

  def test_should_have_role_on_nodes
    assert  users(:editor).has_role_on?("editor", nodes(:devcms_news_node))
    assert !users(:editor).has_role_on?("editor", nodes(:contact_page_node))
    assert  users(:editor).has_role_on?("editor", nodes(:devcms_news_item_node))
    assert  users(:arthur).has_role_on?("admin",  nodes(:devcms_news_item_node))
  end

  def test_should_have_role_with_multiple_roles_on_nodes
    assert  users(:arthur).has_role_on?("final_editor", "admin",  nodes(:economie_section_node))
    assert !users(:arthur).has_role_on?("final_editor", "editor", nodes(:economie_section_node))
    assert  users(:editor).has_role_on?("final_editor", "editor", nodes(:devcms_news_node))
    assert  users(:final_editor).has_role_on?("final_editor", "editor", nodes(:economie_section_node))
    assert !users(:final_editor).has_role_on?(["final_editor", "editor", "admin"], nodes(:devcms_news_node))
  end

  def test_should_have_role_with_multiple_roles_on_root_node
    assert users(:arthur).has_role_on?("final_editor", "admin")
    assert !users(:final_editor).has_role_on?(["final_editor", "editor"])
  end

  def test_should_have_roles
    assert users(:arthur).has_role?("admin", "editor", "final-editor")
    assert !users(:arthur).has_role?("editor", "final-editor")
    assert !users(:normal_user).has_role?(["admin", "editor", "final-editor"])
  end

  def test_should_have_any_role
    assert users(:arthur).has_any_role?
  end
  
  def test_should_not_have_any_role
    assert !users(:normal_user).has_any_role?
  end
  
  def test_should_return_role_on_node
    assert_equal users(:arthur).role_on(nodes(:help_page_node)).name, "admin"
    assert_equal users(:editor).role_on(nodes(:devcms_news_node)).name, "editor"
    assert_nil   users(:editor).role_on(nodes(:contact_page_node))
 end

  def test_should_give_role_on_node
    success = users(:editor).give_role_on("editor", nodes(:contact_page_node))
    assert success
    assert_equal "editor", users(:editor).reload.role_on(nodes(:contact_page_node)).name
  end

  def test_should_remove_role_from_node
    users(:arthur).give_role_on('admin', Node.root)
    users(:arthur).remove_role_from(Node.root)
    assert !users(:arthur).has_role?('admin')
  end

  def test_should_not_fail_on_remove_of_unexisting_role
    users(:arthur).role_assignments.delete_all
    assert_nothing_raised do
      users(:arthur).remove_role_from(Node.root)
    end
  end

  def test_should_strip_sensitive_information_from_xml
    xml = users(:arthur).to_xml
    User::SECRETS.each { |secret| assert !xml.include?(secret.dasherize) }
  end

  def test_should_keep_sensitive_information_in_secrets_xml
    xml = users(:arthur).to_xml_with_secrets
    User::SECRETS.each { |secret| assert xml.include?(secret.dasherize) }
  end

  def test_should_strip_sensitive_information_from_json
    json = users(:arthur).to_json
    User::SECRETS.each { |secret| assert !json.include?(secret) }
  end

  def test_should_keep_sensitive_information_in_secrets_json
    json = users(:arthur).to_json_with_secrets
    User::SECRETS.each { |secret| assert json.include?(secret) }
  end

  def test_has_subscription_for?
    newsletter_archives = NewsletterArchive.all

    User.all.each do |user|
      newsletter_archives.each do |newsletter_archive|
        if user.newsletter_archives.include?(newsletter_archive)
          assert user.has_subscription_for?(newsletter_archive)
        else
          assert !user.has_subscription_for?(newsletter_archive)
        end
      end
    end
  end

  # Verification tests

  def test_verify_should_update_user_without_code
    u = users(:unverified_user)
    u.verify!
    assert u.verified?
  end
  
  def test_should_verify_users_email_address
    u = users(:unverified_user)
    u.update_attribute(:verification_code, '12345')
    assert u.verify_with('12345')
    assert u.verified?
  end

  def test_should_not_verify_user_email_address
    u = users(:unverified_user)
    u.update_attribute(:verification_code, '12345')
    assert !u.verify_with('54321') # Invalid code
    assert !u.verified?
  end

  def test_should_not_update_attrs_on_mass_assign
    u = users(:unverified_user)
    u.update_attribute(:verification_code, '12345')
    u.update_attributes(:verified => true, :verification_code => 'XXX')
    assert !u.verified?
    assert_not_equal 'XXX', u.verification_code
  end

  def test_should_generate_valid_verification_code
    1000.times do # Generate 1000 codes to prevent coincidencial valid format.
      code = User.generate_verification_code_for(users(:sjoerd))
      assert code.is_a?(String)
      assert code =~ /\A[[:alnum:]]{5,}\z/, "'#{code}' is invalid."
    end
  end

  def test_should_require_verification_code
    u = users(:sjoerd)
    u.verification_code = nil
    assert !u.valid?
    assert u.errors.on(:verification_code)
  end

  def test_should_auto_set_attrs_on_create
    u = create_user
    assert !u.verified?
    assert !u.verification_code.blank?
  end

  def test_should_reset_verification_code
    u = users(:sjoerd)
    prev_code = u.verification_code
    u.reset_verification_code
    assert_not_equal u.reload.verification_code, prev_code
  end

  def test_should_generate_password_of_5_alnum_chars
    pw = User.generate_password_for(users(:sjoerd))
    assert pw.is_a?(String)
    assert pw =~ /\A[[:alnum:]]{5}\z/, "'#{pw}' is invalid."
  end

  def test_should_reset_password
    u = users(:sjoerd)
    prev_hash = u.password_hash
    u.reset_password
    assert_not_equal prev_hash, u.reload.password_hash
  end

  def test_should_get_full_name
    assert_equal "Sjoerd Andringa", users(:sjoerd).full_name
  end

  def test_should_not_allow_reserved_logins
    DevCMS.stubs(:reserved_logins_regex).returns(/(burger?meester|wethouder|gemeente|voorlichting)/i)
    [ 'Burgemeester', 'Wethouder', 'Gemeente', 'Voorlichting'].each do |login|
      [ login, login.downcase, login.upcase ].each do |l|
        u = create_user(:login => l)
        assert u.errors.on(:login)
      end
    end
  end

  def test_destruction_of_user_should_destroy_associated_weblogs
    henk = users(:henk)

    assert_difference 'Weblog.count', -1 * henk.weblogs.size do
      henk.destroy
    end
  end

  def test_destruction_of_user_should_destroy_associated_forum_threads
    henk = users(:henk)

    assert_difference 'ForumThread.count', -1 * henk.forum_threads.size do
      henk.destroy
    end
  end
  
  def test_destruction_of_user_should_destroy_associated_forum_posts
    assert_difference 'ForumPost.count', -1 * users(:normal_user).forum_posts.count do
      users(:normal_user).destroy
    end
  end
  
  def test_destruction_of_user_should_not_destroy_associated_comments
    jan = users(:jan)

    assert jan.comments.count > 0
    assert_no_difference 'Comment.count' do
      jan.destroy
    end
  end

  def test_screen_name_should_return_full_name_if_present_else_login
    u = create_user(:login => 'corneel')
    assert_equal 'corneel', u.screen_name
    u = create_user(:login => 'corneel', :first_name => 'Cornelis', :surname => 'van Kaperen')
    assert_equal 'Cornelis van Kaperen', u.screen_name
  end

  def test_to_param_should_return_login
    assert_equal 'corneel', create_user(:login => 'corneel').to_param
  end

  def test_should_send_invitation_email
    ActionMailer::Base.deliveries.clear
    email_address = 'test@test.nl'
    User.send_invitation_email!(email_address)

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.first

    assert email.to.include?(email_address)
  end

  def test_should_not_verify_invitation_code_for_missing_email_address_or_code
    assert !User.verify_invitation_code(nil, nil)
    assert !User.verify_invitation_code(nil, ' ')
    assert !User.verify_invitation_code(' ', nil)
    assert !User.verify_invitation_code(' ', ' ')
    assert !User.verify_invitation_code('test@test.nl', nil)
    assert !User.verify_invitation_code('test@test.nl', ' ')
    assert !User.verify_invitation_code(nil, 'test')
    assert !User.verify_invitation_code(' ', 'test')
  end

  def test_should_not_verify_invitation_code_for_incorrect_code
    assert !User.verify_invitation_code('test@test.nl', 'bla')
  end

  def test_should_verify_invitation_code_for_correct_code
    email_address = 'test@test.nl'
    assert User.verify_invitation_code(email_address, User.send(:generate_invitation_code, email_address))
  end
  
protected

  def create_user(options = {})
    User.create({ :login => 'paashaas', :email_address => 'paas@haas.nl', :password => 'pasen', :password_confirmation => 'pasen' }.merge(options))
  end
end