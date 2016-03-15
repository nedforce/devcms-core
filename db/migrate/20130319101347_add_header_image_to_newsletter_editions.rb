class AddHeaderImageToNewsletterEditions < ActiveRecord::Migration
  def change
    add_column :newsletter_editions, :header_image_node_id, :integer, references: nil
    NewsletterArchive.all.each do |archive|
      image = if archive.header and File.exist?(Rails.root.join('app', 'assets', 'images', 'newsletter', archive.header))
        archive.header
      else
        Settler[:newsletter_archive_header_default]
      end
      Image.create!(file: open(Rails.root.join('app', 'assets', 'images', 'newsletter', image)), title: image, parent: archive.node)
    end
    remove_column :newsletter_archives, :header
    Setting.delete_all(key: 'newsletter_archive_header_default')
    raise 'Migration failed: not all archives have a default header.' if NewsletterArchive.any? && !Node.with_content_type('NewsletterArchive').all? { |nla| nla.children.with_content_type('Image').any? }
  end
end
