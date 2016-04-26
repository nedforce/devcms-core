require 'csv'

# This model is used to represent a response from a contact_form
#
# A +Response+ has many +ResponseField+ objects.
#
# *Specification*
#
# Attributes
#
# * +ip+ - The ip adress of the sender
# * +time+ - The time when the response is sent
#
# Preconditions
#
# * Requires the presence of +ip+, +time+.
#
class Response < ActiveRecord::Base
  belongs_to :contact_form
  has_many :response_fields, dependent: :destroy

  validates :contact_form_id, presence: true
  validates :ip,              presence: true
  validates :time,            presence: true

  def self.to_csv_file(options = {})
    return '' unless any?

    CSV.generate(options) do |csv|
      header_fields = []
      first.contact_form.contact_form_fields.order('position ASC').each do |field|
        header_fields << field.label
      end
      csv << header_fields
      all.each do |response|
        row_fields = []
        response.response_fields.includes(:contact_form_field).order('contact_form_fields.position ASC').each do |field|
          row_fields << field.csv_value
        end
        csv << row_fields
      end
    end
  end
end
