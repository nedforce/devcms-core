class UserMailer < ActionMailer::Base
  
  add_template_helper(ActionView::Helpers::UrlHelper)
  add_template_helper(ActionView::Helpers::RoutingHelpers)
  
  def verification_email(user, options = {})
    set_defaults(user, options)
    @subject      = "Welkom bij #{Settler[:host]}. Verifieer uw e-mailadres!"
    @body[:user]  = user
  end
  
  def invitation_email(email_address, invitation_code, options = {})
    @recipients              = email_address
    @from                    = Settler[:mail_from_address]
    @sent_on                 = Time.now
    @subject                 = "U bent uitgenodigd voor www.#{Settler[:host]}."
    @body[:host]             = options[:host] || Settler[:host]
    @body[:invitation_email] = email_address
    @body[:invitation_code]  = invitation_code
  end

  def password_reminder(user, new_password, options = {})
    set_defaults(user, options)
    @subject         = "Uw #{Settler[:host]} wachtwoord."
    @body[:user]     = user
    @body[:password] = new_password
  end

  def rejection_notification(user, node, reason, options = {})
    set_defaults(node.editor, options)
    headers("Reply-To" => "#{user.full_name} <#{user.email_address}>")
    @subject       = "Wijziging aan #{Settler[:host]}/#{node.url_alias} afgewezen."
    @body[:user]   = user
    @body[:node]   = node
    @body[:reason] = reason
  end

  def approval_notification(user, node, comment, options = {})
    set_defaults(node.editor, options)
    headers("Reply-To" => "#{user.full_name} <#{user.email_address}>")

    @subject        = "Wijziging aan #{Settler[:host]}/#{node.url_alias} goedgekeurd."
    @body[:user]    = user
    @body[:node]    = node
    @body[:comment] = comment
  end

  def new_forum_post_notification(thread_owner, post)
    set_defaults(thread_owner, {})

    @subject       = "Nieuwe reactie op forum '#{post.forum_thread.title}'"
    @body[:user]   = thread_owner
    @body[:post]   = post
    @body[:topic]  = post.forum_thread.forum_topic
    @body[:thread] = post.forum_thread
  end

  protected

  def set_defaults(user, options)
    @recipients  = user.email_address
    @from        = Settler[:mail_from_address]
    @body[:host] = options[:host] || Settler[:host]
    @sent_on     = Time.now
  end

end
