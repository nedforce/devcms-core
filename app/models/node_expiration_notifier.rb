class NodeExpirationNotifier < ActionMailer::Base
  def notification_for(author,nodes)
    # TODO: CODE NOG SCHRIJVEN, GESTOLEN VAN NEWSLETTER SUBSCRIPTION
     # unless edition.newsletter_archive.users.include?(user)
     #       raise "User #{user.id} is not subscribed to archive #{edition.newsletter_archive.id} for edition #{edition.id}!"
     #     end
     # 
     #     default_url_options[:host] = host = "#{Settler[:host]}"
     #     archive = edition.newsletter_archive
     # 
     #     implicit_parts_order ["text/html", "text/plain"]
     #     from         archive.from_email_address.blank? ? Settler[:mail_from_address] : archive.from_email_address
     #     subject      "[#{archive.title}] #{edition.title}"
     #     recipients   user.email_address
     #     sent_on      Time.now
     #     body        :newsletter_edition => edition, :user => user, :host => host
  end
end
