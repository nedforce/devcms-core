require File.expand_path('../../test_helper.rb', __FILE__)

class UserMailerTest < ActionMailer::TestCase
  self.use_transactional_fixtures = true

  tests UserMailer

  def test_invitation_email
    email_address = 'ditiseenemailadres'
    invitation_code = 'ditiseeninvitationcode'
    email = UserMailer.invitation_email(email_address, invitation_code)
    body = email.parts.first.body

    assert email.to.to_s =~ /#{email_address}/
    assert body =~ /#{invitation_code}/
    assert body =~ /#{email_address}/
  end

  def test_verification_email
    user = users(:sjoerd)
    email = UserMailer.verification_email(user)
    body = email.parts.first.body

    assert email.to.to_s =~ /#{user.email_address}/
    assert body =~ /#{user.verification_code}/
  end

  def test_password_reset
    user = users(:sjoerd)
    response = UserMailer.password_reset(user)
    body = response.parts.first.body

    assert response.to.to_s =~ /#{user.email_address}/
    assert body =~ /e5e9fa1ba31ecd1ae84f75caaa474f3a663f05f4/
  end

  def test_rejection_notification
    user = users(:arthur)
    node = nodes(:help_page_node)
    editor = users(:gerjan)
    reason = 'rejected'

    response = UserMailer.rejection_notification(user, node, editor, reason)
    body = response.parts.first.body

    assert response.reply_to.to_s =~ /#{user.email_address}/
    assert response.to.to_s =~ /#{editor.email_address}/
    assert body =~ /#{node.url_alias}/
    assert body =~ /#{reason}/
  end

  def test_approval_notification
    user = users(:arthur)
    node = nodes(:help_page_node)
    editor = users(:gerjan)
    comment = 'approved'

    response = UserMailer.approval_notification(user, node, editor, comment)
    body = response.parts.first.body

    assert response.reply_to.to_s =~ /#{user.email_address}/
    assert response.to.to_s =~ /#{editor.email_address}/
    assert body =~ /#{node.url_alias}/
    assert body =~ /#{comment}/
  end

  def test_new_forum_post_notification
    thread = forum_threads(:bewoners_forum_thread_one)
    post = ForumPost.create(forum_thread: thread, user: users(:sjoerd), body: 'Enjoy!')

    response = UserMailer.new_forum_post_notification(thread.user, post)
    body = response.parts.first.body

    assert response.to.to_s =~ /#{thread.user.email_address}/
    assert body.include?(post.user.full_name)
    assert body.include?('heeft de volgende reactie geplaatst in de discussie')
    assert body.include?(post.body)
  end
end
