class ContactFormMailer < ActionMailer::Base

  def contact_message(contact_form, entered_fields)
    @recipients            = contact_form.email_address
    @from                  = Settler[:mail_from_address]
    @sent_on               = Time.now
    @subject               = contact_form.title
    @entered_fields        = entered_fields
   
    entered_fields.select{|field| field[:value].is_a?(Tempfile) }.each do |field|
      attachments[field[:value].original_filename] = field[:value].read  
    end
    
    mail(:from => @from, :to => @recipients, :subject => @subject)     
  end
end
