module DevcmsCore
  # Cleans old uploads (files) that should be no longer present.
  class UploaderCleaner
    class << self
      def attachment_root
        @attachment_root ||= AttachmentUploader.new.root.join('private/uploads/attachment/file/')
      end

      def image_root
        @image_root ||= AttachmentUploader.new.root.join('private/uploads/image/file/')
      end

      def attachments_in_database
        Attachment.unscoped.map(&:id).sort
      end

      def images_in_database
        Image.unscoped.map(&:id).sort
      end

      def attachments_on_disk
        Dir[attachment_root.join('*')].map { |d| d.gsub(attachment_root.to_s, '').to_i }.sort
      end

      def images_on_disk
        Dir[image_root.join('*')].map { |d| d.gsub(image_root.to_s, '').to_i }.sort
      end

      def attachment_folders_for_removal
        @attachment_folders_for_removal ||= attachments_on_disk - attachments_in_database
      end

      def image_folders_for_removal
        @image_folders_for_removal ||= images_on_disk - images_in_database
      end

      def delete_attachment_folders_to_remove
        attachment_folders_for_removal.each do |f|
          FileUtils.rm_r "#{attachment_root}#{f}", secure: true
        end
      end

      def delete_image_folders_to_remove
        image_folders_for_removal.each do |f|
          FileUtils.rm_r "#{image_root}#{f}", secure: true
        end
      end
    end
  end
end
