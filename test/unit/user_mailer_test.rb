require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  self.use_transactional_fixtures = true

  tests UserMailer

  def test_invitation_email
    email_address = 'ditiseenemailadres'
    invitation_code = 'ditiseeninvitationcode'
    email = UserMailer.create_invitation_email(email_address, invitation_code)

    assert email.to.to_s =~ /#{email_address}/
    assert email.body =~ /#{invitation_code}/
    assert email.body =~ /#{email_address}/
  end

  def test_verification_email
    user = users(:sjoerd)
    email = UserMailer.create_verification_email(user)
    assert email.to.to_s =~ /#{user.email_address}/
    assert email.body =~ /#{user.verification_code}/
  end

  def test_password_reminder
    user = users(:sjoerd)
    response = UserMailer.create_password_reminder(user, 'newpass')
    assert response.to.to_s =~ /#{user.email_address}/
    assert response.body =~ /newpass/
  end

  def test_rejection_notification
    node = nodes(:unapproved_page_node)
    user = users(:sjoerd)
    reason = 'rejection'
    response = UserMailer.create_rejection_notification(user, node, reason)
    assert response.reply_to.to_s =~ /#{user.email_address}/
    assert response.to.to_s =~ /#{node.editor.email_address}/
    assert response.body =~ /#{node.url_alias}/
    assert response.body =~ /#{reason}/
  end

  def test_approval_notification
    node = nodes(:unapproved_page_node)
    user = users(:sjoerd)
    comment = 'approval'
    response = UserMailer.create_approval_notification(user, node, comment)
    assert response.reply_to.to_s =~ /#{user.email_address}/
    assert response.to.to_s =~ /#{node.editor.email_address}/
    assert response.body =~ /#{node.url_alias}/
    assert response.body =~ /#{comment}/
  end

  def test_new_forum_post_notification
    thread = forum_threads(:bewoners_forum_thread_one)
    post = ForumPost.create({ :forum_thread => thread, :user => users(:sjoerd), :body => "Enjoy!" })

    response = UserMailer.create_new_forum_post_notification(thread.user, post)
    assert response.to.to_s =~ /#{thread.user.email_address}/
    assert response.body.include?(post.user.full_name)
    assert response.body.include?("heeft de volgende reactie geplaatst in de discussie")
    assert response.body.include?(post.body)
  end
end

