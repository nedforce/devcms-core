class NewsletterArchivesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :newsletter_archive

  validates :user_id, uniqueness: { scope: :newsletter_archive_id }
end
