class AddHeaderToNewsletterArchive < ActiveRecord::Migration
  def self.up
    add_column :newsletter_archives, :header, :string
  end

  def self.down
    remove_column :newsletter_archives, :header
  end
end
