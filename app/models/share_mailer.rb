class ShareMailer < ActionMailer::Base

  def recommendation_email(share, options = {})
    @recipients   = "#{share.to_name} <#{share.to_email_address}>"
    @from         = Settler[:mail_from_address]
    @subject      = share.subject
    @sent_on      = Time.now
    @body[:share] = share
  end
end
