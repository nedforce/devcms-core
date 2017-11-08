class AddHashToNewsletterArchivesUsers < ActiveRecord::Migration
  def up
    add_column :newsletter_archives_users, :identifier_hash, :string, unique: true
    NewsletterArchivesUser.all.each(&:generate_hash)
  end

  def down
    remove_column :newsletter_archives_users, :identifier_hash
  end
end
