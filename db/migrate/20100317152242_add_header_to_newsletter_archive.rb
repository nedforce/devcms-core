class AddHeaderToNewsletterArchive < ActiveRecord::Migration
  def up
    add_column :newsletter_archives, :header, :string
  end

  def down
    remove_column :newsletter_archives, :header
  end
end
