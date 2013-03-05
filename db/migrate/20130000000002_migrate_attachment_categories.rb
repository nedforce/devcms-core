class MigrateAttachmentCategories < ActiveRecord::Migration
  def self.up
    Attachment.all(:conditions => "category != ''").each do |attachment|
      next if attachment.parent.title == attachment.category && attachment.parent.sub_content_type == 'AttachmentTheme'
      p "Attachment #{attachment.id} with category #{attachment.category}..."
      if theme = attachment.parent.children.with_content_type("AttachmentTheme").find_by_title(attachment.category)
        p "Found theme: #{theme.title}"
      else
        theme = AttachmentTheme.create(:title => attachment.category, :parent => attachment.parent).node if theme.blank?
        p "Created theme: #{theme.title}"
      end
      attachment.update_attributes :parent => theme
      p "Moved attachment #{attachment.title} to theme #{theme.title}"
    end
    if Attachment.all(:conditions => "category != ''").any? {|attachment| attachment.parent.title != attachment.category }
      raise "Something went wrong, rolling back.."
    end
    remove_column :attachments, :category
  end

  def self.down
  end
end
