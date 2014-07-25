class ContactFormMailer < ActionMailer::Base

  def message(contact_form, entered_fields)
    @recipients            = contact_form.email_address
    @from                  = Settler[:mail_from_address]
    @sent_on               = Time.now
    @subject               = contact_form.title

    part "text/html" do |p|
      p.body = render_message('message.text.html', :title => contact_form.title, :entered_fields => entered_fields)
    end

    part "text/plain" do |p|
      p.body = render_message('message.text.plain', :title => contact_form.title, :entered_fields => entered_fields)    
    end

    entered_fields.select{ |field| field[:value].is_a?(Tempfile) }.each do |field|
      attachment :content_type => field[:value].content_type.chomp, :body => field[:value].read, :filename => field[:value].original_filename
    end
  end
end
