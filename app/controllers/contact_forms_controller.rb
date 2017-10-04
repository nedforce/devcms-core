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
    @errors = {}
    @entered_fields = []

    respond_to do |format|
      format.html # show.html.haml
    end
  end

  # * POST /contact_forms/:id/send_message
  def send_message
    @contact_form_field = params[:contact_form_field]

    @errors = {}

    get_entered_fields

    respond_to do |format|
      @errors = check_errors(@contact_form_field)
      if @errors.any?
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
  # Check whether all email_address fields are actually an e-mail address.
  # Returns errors
  #
  # TODO: Rename `array` argument to something more clear. The name array is
  #       vague. It is an error of what?
  def check_errors(array)
    # TODO: A better name is `errors_hash` or just `errors`. The 'check' part
    #       does not add anything to the meaning.
    check_errors_hash = {}
    if array.present?
      @contact_form.obligatory_field_ids.each do |field_id|
        # TODO: String interpolation is not necessary here.
        #  See http://ruby-doc.org/core-2.4.2/Hash.html
        if array["#{field_id}"].blank?

          # TODO: The `check_errors_hash` contains the translation key of the
          # error message rather than the error message itself. I think the
          # latter is a bit better because it keeps the view more clean.
          check_errors_hash["#{field_id}"] = 'contact_forms.should_enter_obligatory_field'
        end
      end
      @contact_form.email_address_field_ids.each do |field_id|

        # TODO: String interpolation is not necessary here.
        if array["#{field_id}"].present? && array["#{field_id}"] !~ EmailValidator::REGEX
          check_errors_hash["#{field_id}"] = 'contact_forms.should_enter_valid_email_address'
        end
      end
    end
    check_errors_hash
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
