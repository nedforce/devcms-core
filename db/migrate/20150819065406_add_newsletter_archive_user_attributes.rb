class AddNewsletterArchiveUserAttributes < ActiveRecord::Migration
  def change
    add_column :newsletter_archives_users, :id, :primary_key
    add_column :newsletter_archives_users, :created_at, :datetime
    add_column :newsletter_archives_users, :updated_at, :datetime
  end
end
