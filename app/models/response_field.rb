class ResponseField < ActiveRecord::Base
  belongs_to :response
  belongs_to :contact_form_field

  mount_uploader :file, ResponseFileUploader

  serialize :value

  def csv_value
    if value.blank?
      ''
    elsif file?
      read_attribute(:file)
    else
      value
    end
  end
end
