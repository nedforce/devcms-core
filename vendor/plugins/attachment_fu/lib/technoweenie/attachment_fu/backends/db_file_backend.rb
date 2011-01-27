module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Backends
      # Methods for DB backed attachments
      module DbFileBackend
        def self.included(base) #:nodoc:
          Object.const_set(:DbFile, Class.new(ActiveRecord::Base)) unless Object.const_defined?(:DbFile)
          base.belongs_to  :db_file, :class_name => '::DbFile', :foreign_key => 'db_file_id'
        end

        # Creates a temp file with the current db data.
        def create_temp_file
          file_name = File.join(Technoweenie::AttachmentFu.tempfile_path, random_tempfile_filename)
          self.class.transaction do
            self.connection.raw_connection.lo_export(self.db_file.loid, file_name)
          end
          return file_name
        end
        
        # Gets the current data from the database
        def current_data
          return File.read(create_temp_file)
        end
        
        protected
          # Destroys the file.  Called in the after_destroy callback
          def destroy_file
            if db_file && !db_file.loid.blank?
              self.connection.raw_connection.lo_unlink(db_file.loid)
              db_file.destroy 
            end
          end
          
          # Saves the data to the DbFile model
          def save_to_storage
            if save_attachment?
              (db_file || build_db_file).loid = self.connection.raw_connection.lo_import(temp_path)
              raise "LO creation failed!" if db_file.loid.nil?
              #(db_file || build_db_file).data = temp_data
              db_file.save!
              self.class.update_all ['db_file_id = ?', self.db_file_id = db_file.id], ['id = ?', id]
            end
            true
          end
      end
    end
  end
end