class ResponseField < ActiveRecord::Base
  belongs_to :response
  belongs_to :contact_form_field

  mount_uploader :file, ResponseFileUploader
    
  serialize :value
  
end
