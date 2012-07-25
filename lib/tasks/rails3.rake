namespace :rails3 do
  desc "Converts DbFile attachments to Carrierwave attachments"
  task :convert_dbfile_attachments, [:overwrite] => :environment do |t, args|    
    unless Attachment.new.respond_to?(:file?)
      p "the Attachment model needs a 'file' string column and a mounted Carrierwave uploader"
      exit(1) 
    end

    Attachment.unscoped do
      Node.unscoped do
        Attachment.find_in_batches do |attachments|  
          attachments.each do |attachment|
            p "Converting attachment ##{attachment.id}..."

            if attachment.file? && !args[:overwrite]
              p "Attachment ##{attachment.id} already has an associated file, skipping (execute rake rails3:convert_dbfile_attachments[true] to overwrite)"
              next
            end

            store_dir = File.join(Rails.root, attachment.file.store_dir)
            file_name = attachment.filename        

            FileUtils.mkdir_p store_dir
            new_file_path = File.join(store_dir, file_name)

            Attachment.transaction do  
              attachment.connection.raw_connection.lo_export(attachment.db_file.loid, new_file_path)                  
              attachment.send(:write_attribute, :file, file_name)
              attachment.save!(Rails.version.to_i < 3 ? false : { :validate => false})
            end

            p "Attachment ##{attachment.id} updated!"            
          end
        end
      end
    end

    true
  end

  desc "Converts images to Carrierwave images"
  task :convert_images, [:overwrite] => :environment do |t, args|    
    unless Image.new.respond_to?(:file?)
      p "the Image model needs a 'file' string column and a mounted Carrierwave uploader"
      exit(1) 
    end

    Image.unscoped do
      Node.unscoped do
        Image.find_in_batches(:select => '*') do |images|  
          images.each do |image|
            p "Converting image ##{image.id}..."

            if image.file? && !args[:overwrite]
              p "Image ##{image.id} already has an associated file, skipping (execute rake rails3:convert_images[true] to overwrite)"
              next
            end

            store_dir = File.join(Rails.root, image.file.store_dir)
            file_name = image.title.gsub(/[^a-z0-9\-_]/i, '-') + '.jpg'

            FileUtils.mkdir_p store_dir
            new_file_path = File.join(store_dir, file_name)

            File.open(new_file_path, 'wb'){ |f| f << image.data }
            image.send(:write_attribute, :file, file_name)
            image.save!(Rails.version.to_i < 3 ? false : { :validate => false})
            image.file.recreate_versions!    

            p "Image ##{image.id} updated!"       
          end
        end
      end
    end

    true
  end
end
