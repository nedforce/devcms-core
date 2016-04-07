module DevcmsCore
  class MailUtils
    # Deal with invalid user-input in an e-mail address and display name
    def self.escape_email_address(email, display_name = nil)
      address = Mail::Address.new email
      address.display_name = display_name.dup if display_name
      address.format
    end
  end
end
