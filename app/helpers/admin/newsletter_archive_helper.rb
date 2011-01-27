module Admin::NewsletterArchiveHelper
  def newsletter_archive_options_for_select
    NewsletterArchive.header_images.map do |name|
      [name.gsub(/\.\w+/, '').humanize, name]
    end
  end
end
