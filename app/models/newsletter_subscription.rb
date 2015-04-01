class NewsletterSubscription < ActionMailer::Base
  def edition_for(edition, user)
    unless edition.newsletter_archive.users.include?(user)
      raise "User #{user.id} is not subscribed to archive #{edition.newsletter_archive.id} for edition #{edition.id}!"
    end

    default_url_options[:host] = "#{Settler[:host]}" if default_url_options[:host].blank?
    host = default_url_options[:host]
    archive = edition.newsletter_archive

    implicit_parts_order ["text/html", "text/plain"]
    from         archive.from_email_address.blank? ? Settler[:mail_from_address] : archive.from_email_address
    subject      edition.mail_subject
    recipients   user.email_address
    sent_on      Time.now
    body        :newsletter_edition => edition, :user => user, :host => host
  end
end
