class UserMailer < ActionMailer::Base
  add_template_helper(ActionView::Helpers::UrlHelper)
  add_template_helper(DevcmsCore::RoutingHelpers)

  def verification_email(user, options = {})
    set_defaults(user, options)
    @subject = "Welkom bij #{Settler[:host]}. Verifieer uw e-mailadres!"
    @user    = user

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def email_used_to_create_account(user, options = {})
    set_defaults(user, options)
    @subject = "Uw e-mail is gebruikt om een account te maken bij #{Settler[:host]}"
    @user    = user

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def invitation_email(email_address, invitation_code, options = {})
    @recipients       = email_address
    @from             = Settler[:mail_from_address]
    @subject          = "U bent uitgenodigd voor www.#{Settler[:host]}."
    @host             = options[:host] || Settler[:host]
    @invitation_email = email_address
    @invitation_code  = invitation_code

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def password_reset(user, options = {})
    set_defaults(user, options)
    @subject = "Uw #{Settler[:host]} wachtwoord opnieuw instellen"
    @user    = user

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def account_does_not_exist(email_address, options = {})
    @recipients       = email_address
    @from             = Settler[:mail_from_address]
    @subject          = "Uw #{Settler[:host]} account."
    @host             = options[:host] || Settler[:host]
    @invitation_email = email_address

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def rejection_notification(user, node, editor, reason, options = {})
    set_defaults(editor, options)
    headers('Reply-To' => "#{user.full_name} <#{user.email_address}>")

    @subject = "Wijziging aan #{Settler[:host]}/#{node.url_alias} afgewezen."
    @user    = user
    @node    = node
    @editor  = editor
    @reason  = reason

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def approval_notification(user, node, editor, comment, options = {})
    set_defaults(editor, options)
    headers('Reply-To' => "#{user.full_name} <#{user.email_address}>")

    @subject = "Wijziging aan #{Settler[:host]}/#{node.url_alias} goedgekeurd."
    @user    = user
    @node    = node
    @editor  = editor
    @comment = comment

    mail(from: @from, to: @recipients, subject: @subject)
  end

  def new_forum_post_notification(thread_owner, post)
    set_defaults(thread_owner, {})

    @subject = "Nieuwe reactie op forum '#{post.forum_thread.title}'"
    @user    = thread_owner
    @post    = post
    @topic   = post.forum_thread.forum_topic
    @thread  = post.forum_thread

    mail(from: @from, to: @recipients, subject: @subject) do |format|
      format.text
      format.html
    end
  end

  protected

  def set_defaults(user, options)
    @recipients  = user.email_address
    @from        = Settler[:mail_from_address]
    @host        = options[:host] || Settler[:host]
  end

  ActiveSupport.run_load_hooks(:user_mailer, self)
end
