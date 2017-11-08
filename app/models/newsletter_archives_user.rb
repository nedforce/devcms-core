class NewsletterArchivesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :newsletter_archive
  
  validates :user_id, uniqueness: { scope: :newsletter_archive_id }

  before_save :generate_hash

  def generate_hash
    return if self.identifier_hash.present?

    begin
      hash = SecureRandom.urlsafe_base64 32
    end while NewsletterArchivesUser.exists?(identifier_hash: hash)
    self.update_attributes(identifier_hash: hash)
  end

end
