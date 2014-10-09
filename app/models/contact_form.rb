# This model is used to represent a contact form. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# A +ContactForm+ has many +ContactFormField+ objects.
#
# *Specification*
# 
# Attributes
# 
# * +title+ - The title of the contact form.
# * +email_address+ - The email address to which contact requests are send; typically an email address of an editor or administrator.
# * +description_before_contact_fields+ - The description of the contact form (printed before the actual contact fields).
# * +description_after_contact_fields+ - The description of the contact form (printed after the actual contact fields).
# * +send_method+ - The way of storing/sending the email. See constants
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +email_address+.
# * Requires +email_address+ to be a valid email address.
#
class ContactForm < ActiveRecord::Base
  # Constants for different sendmethods. Used in the send_method column in the table
  SEND_METHOD_MAIL     = 0
  SEND_METHOD_DATABASE = 1

  acts_as_content_node

  # A +ContactForm+ has many +ContactFormField+ objects.
  has_many :contact_form_fields, :dependent => :destroy
  has_many :responses,           :dependent => :destroy

  # Ensure the +ContactFormFields+ are valid, build on creation of the +ContactForm+,
  # and updated and deleted when necessary.
  before_validation :build_contact_form_fields
  validate          :validate_updated_contact_form_fields
  after_validation  :set_error_messages_for_contact_form_fields
  after_save        :destroy_deleted_contact_form_fields, :save_updated_contact_form_fields

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :title, :email_address
  validates_length_of       :title, :in => 2..255, :allow_blank => true
  validates_email_format_of :email_address,        :allow_blank => true

  # Virtual attribute to keep track of submitted +ContactFormField+ objects.
  attr_accessor :contact_form_fields_before_save

  # Virtual attribute to keep track of +ContactFormField+ objects that need to be deleted.
  attr_accessor :deleted_contact_form_fields

  after_paranoid_delete :remove_associated_content

  # Returns an array with the ids of the +ContactFormField+ objects that are obligatory.
  def obligatory_field_ids
    contact_form_fields.obligatory.map { |field| field.id }
  end

  def email_address_field_ids
    contact_form_fields.has_field_type('email_address').map { |field| field.id }
  end

  protected

  # Builds the +ContactFormField+ objects, before they are validated.
  def build_contact_form_fields
    self.deleted_contact_form_fields = {}

    @deleted_contact_form_fields = []

    unless @contact_form_fields_before_save.blank? || !@contact_form_fields_before_save.is_a?(Array)
      @contact_form_fields_before_save.delete_if { |options| options.values.all? { |value| value.blank? } }
      @contact_form_fields_before_save.each do |options|
        inst = nil
        delete_contact_form_field = options.delete(:delete)
        contact_form_field_id     = options.delete(:id)
        if contact_form_field_id && !self.new_record?
          if delete_contact_form_field == '1'
            @deleted_contact_form_fields << contact_form_field_id
          else
            inst = self.contact_form_fields.select { |s| s.id == contact_form_field_id.to_i }.first
            inst.attributes = options
          end
        else
          inst = ContactFormField.new(options.merge({ :contact_form => self }.merge(options)))
          self.contact_form_fields << inst
        end
      end
      # @contact_form_fields_before_save = nil
    end
  end

  # Destroy the +ContactFormField+ objects listed for destruction.
  def destroy_deleted_contact_form_fields
    self.deleted_contact_form_fields.each do |ids|
      ContactFormField.delete_all(:id => ids) unless ids.empty?
    end
  end

  # Validate the +ContactFormField+ objects that are updated.
  def validate_updated_contact_form_fields
    self.errors.add(:contact_form_fields, :invalid_contact_form_field) unless self.contact_form_fields.all? { |s| s.valid? || s.new_record? }
  end

  # Save the +ContactFormField+ objects that are updated.
  def save_updated_contact_form_fields
    self.contact_form_fields.each { |cff| cff.save unless cff.new_record? || !cff.changed? }
  end

  # Set error messages for the +ContactFormField+ objects after validation.
  def set_error_messages_for_contact_form_fields
    message = I18n.t 'activerecord.errors.models.contact_form.attributes.contact_form_fields.invalid_contact_form_field'

    if self.errors.on("contact_form_fields").present?
      self.errors.instance_eval do
        @errors["contact_form_fields"] = [message]
      end
    end
  end

  def remove_associated_content
    self.contact_form_fields.destroy_all
    self.responses.destroy_all
  end
end
