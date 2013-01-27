# This model is used to represent a contact form field, which are used in a contact form.
#
# A +ContactFormField+ belongs to a +ContactForm+.
#
# *Specification*
# 
# Attributes
# 
# * +label+ - The label of the contact form field.
# * +field_type+ - The type of the contact form field (e.g. input field, textarea).
# * +position+ - The position of the contact form field relative to the other fields.
# * +obligatory+ - Whether the contact form field is obligatory (true) or optional (false) to fill out.
# * +default_value+ - The default value of the contact form field.
#
# Preconditions
#
# * Requires the presence of +label+.
# * Requires the presence of +field_type+.
# * Requires the presence of +position+.
# * Requires +label+ to be a string of 1 to 255 characters.
# * Requires +position+ to be an integer.
# * Requires +position+ to be unique for a certain +ContactForm+ object.
#
class ContactFormField < ActiveRecord::Base
  FIELD_TYPES = [ 'textfield', 'textarea', 'dropdown', 'multiselect', 'date', 'file', 'email_address' ]

  # A +ContactFormField+ belongs to a +ContactForm+.
  belongs_to :contact_form

  has_many :response_fields, :dependent => :destroy

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :label, :position
  # We set :allow_blank => true on the validations below,
  # to make sure validates_presence_of is the only message displayed if the validation fails.
  validates_length_of       :label, :in => 1..255, :allow_blank => true
  validates_numericality_of :position,             :allow_blank => true

  validates_inclusion_of    :field_type, :in => ContactFormField::FIELD_TYPES
  validates_uniqueness_of   :position, :scope => :contact_form_id, :message => I18n.t('activerecord.errors.models.contact_form_field.attributes.position.must_be_unique')

  named_scope :obligatory, { :conditions => { :obligatory => true }}
  named_scope :has_field_type, lambda { |field_type| { :conditions => { :field_type => field_type }} }

  def self.human_field_type_for(field_type)
    I18n.t(field_type, :scope => 'contact_form_fields')
  end

end
