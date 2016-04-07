class ShareMailer < ActionMailer::Base
  def recommendation_email(share, _options = {})
    @recipients = DevcmsCore::MailUtils.escape_email_address(share.to_email_address, share.to_name)
    @from       = Settler[:mail_from_address]
    @subject    = share.subject
    @sent_on    = Time.now
    @share      = share

    mail(from: @from, to: @recipients, subject: @subject)
  end
end
