# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +ContactForm+ objects.
class ContactFormsController < ApplicationController
  # The +show+, +edit+, +update+ and +destroy+ actions
  # each need a +ContactForm+ object to work with/act on.
  before_action :find_contact_form,        only: [:show, :send_message]
  before_action :find_contact_form_fields, only: [:show, :send_message]
  around_action :check_honeypot,           only: :send_message

  # SSL is obligatory here for the authenticity token.
  ssl_required :show, :send_message

  # * GET /contact_forms/:id
  def show
    @entered_fields = []

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # * POST /contact_forms/:id/send_message
  def send_message
    @contact_form_field = params[:contact_form_field]

    get_entered_fields

    respond_to do |format|
      @obligatory_error    = true unless entered_all_obligatory_fields?(@contact_form_field)
      @email_address_error = true unless valid_email_address_fields?(@contact_form_field)

      if @obligatory_error || @email_address_error
        format.html { render action: 'show' }
      else
        # Check for send method
        if @contact_form.send_method == ContactForm::SEND_METHOD_DATABASE
          # Store response to database
          # Create a new response object
          @response_row = Response.create!(contact_form: @contact_form, ip: request.remote_ip, time: Time.now, email: current_user.try(:email_address))
          @response_row.save

          # Create response_field objects
          @entered_fields.each do |field|
            response_field = ResponseField.new(response: @response_row, contact_form_field_id: field[:id])

            if field[:type] == 'file'
              response_field.file  = field[:value]
              response_field.value = field[:value].try(:original_filename)
            else
              response_field.value = field[:value]
            end

            response_field.save!
          end

        else
          ContactFormMailer.contact_message(@contact_form, @entered_fields).deliver_now
        end

        format.html # send_message.html.erb
      end
    end
  end

  protected

  # Finds the +ContactForm+ object corresponding to the passed in +id+
  # parameter.
  def find_contact_form
    @contact_form = @node.content
  end

  # Find the +ContactFormField+ objects related to the +ContactForm+.
  def find_contact_form_fields
    @contact_form_fields = @contact_form.contact_form_fields.order(:position)
  end

  # Check the fields entered by the user to only use fields that are actually
  # +ContactFormField+ objects, as we do not want the user to add different
  # input data.
  def get_entered_fields
    @entered_fields = get_used_fields_only(@contact_form_field)
    @entered_fields
  end

  def get_used_fields_only(contact_field)
    used_fields = []

    if contact_field.present?
      @contact_form_fields.each do |field|
        if contact_field["#{field.id}"].present?
          if field.multiselect?
            value = contact_field["#{field.id}"].join(';')
          else
            value = contact_field["#{field.id}"]
          end
        else
          # Make sure an empty field is not nil, so that the exported XLS stays
          # correctly formatted.
          value = ''
        end

        used_fields << { id: field.id, label: field.label, value: value, type: field.field_type }
      end
    end

    used_fields
  end

  # Check whether all obligatory fields are entered.
  # Returns +true+ if this is the case, +false+ otherwise.
  def entered_all_obligatory_fields?(array)
    @contact_form.obligatory_field_ids.each do |field_id|
      if array.blank? || array["#{field_id}"].blank?
        return false
      end
    end

    true
  end

  # Check whether all email_address fields are actually an e-mail address.
  # Allow empty fields, because it is the responsibility of the obligatory
  # setting to check for presence.
  # Returns +true+ if the e-mail addresses are valid, +false+ otherwise.
  def valid_email_address_fields?(array)
    if array.present?
      @contact_form.email_address_field_ids.each do |field_id|
        if array["#{field_id}"].present? && array["#{field_id}"] !~ EmailValidator::REGEX
          return false
        end
      end
    end

    true
  end

  def check_honeypot
    if filled_check && empty_check
      yield
    else
      head :unprocessable_entity
    end
  end

  def filled_check
    params[Rails.application.config.honeypot_name] == Rails.application.config.honeypot_value
  end

  def empty_check
    params[Rails.application.config.honeypot_empty_name] == ''
  end
end
