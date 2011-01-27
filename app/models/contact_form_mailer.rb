class ContactFormMailer < ActionMailer::Base

  def message(contact_form, entered_fields)
    @recipients            = contact_form.email_address
    @from                  = Settler[:mail_from_address]
    @sent_on               = Time.now
    @subject               = contact_form.title
    @body[:title]          = contact_form.title
    @body[:entered_fields] = entered_fields
  end
end
