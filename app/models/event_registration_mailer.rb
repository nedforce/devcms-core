class EventRegistrationMailer < ActionMailer::Base

  def registrations_notification(event, options = {})
    @user         = event.node.created_by
    @recipients   = "#{@user.full_name} <#{@user.email_address}>"
    @from         = Settler[:mail_from_address]
    @subject      = "Gasten voor het evenement #{event.title}"
    @sent_on      = Time.now
    @body[:user]  = @user
    @body[:event] = event
    @body[:host]  = options[:host] || Settler[:host]
  end

end
