class NewsletterSubscriptionMailer < ActionMailer::Base
  add_template_helper(WhiteListHelper)

  def edition_for(edition, user)
    unless edition.newsletter_archive.users.include?(user)
      raise "User #{user.id} is not subscribed to archive #{edition.newsletter_archive.id} for edition #{edition.id}!"
    end

    default_url_options[:host] = host = Settler[:host]
    archive = edition.newsletter_archive

    @from               = archive.from_email_address.blank? ? Settler[:mail_from_address] : archive.from_email_address
    @subject            = "[#{archive.title}] #{edition.title}"
    @recipients         = user.email_address
    @newsletter_edition = edition
    @user               = user
    @host               = host
    @unsubscribe_hash   = NewsletterArchivesUser.where(user_id: @user.id, newsletter_archive_id: archive.id).first.identifier_hash

    mail(from: @from, to: @recipients, subject: @subject)
  end
end
