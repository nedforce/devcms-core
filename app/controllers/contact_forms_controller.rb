# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +ContactForm+ objects.
class ContactFormsController < ApplicationController

  # The +show+, +edit+, +update+ and +destroy+ actions
  # each need a +ContactForm+ object to work with/act on.
  before_filter :find_contact_form
  before_filter :find_contact_form_fields

  # * GET /contact_forms/:id
  def show
    @entered_fields = []

    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # * POST /contact_forms/:id/send_message
  def send_message
    @contact_form_field = params[:contact_form_field]
    
    get_entered_fields
    respond_to do |format|
      if entered_all_obligatory_fields?(@contact_form_field)
       
        # Check for send method
        if @contact_form.send_method == ContactForm::SEND_METHOD_DATABASE
          # Store response to database
          # Create a new response object
          @response_row = Response.create!(:contact_form => @contact_form, :ip => request.remote_ip, :time => Time.now)
          @response_row.save
          # Create response_field objects
          @entered_fields.each do |field|
            ResponseField.create!(:response => @response_row, :contact_form_field_id => field[0], :value => field[2])
          end
        else
          # Send response over e-mail
          ContactFormMailer.deliver_message(@contact_form, @entered_fields)
        end
        format.html # send_message.html.erb
      else
        @obligatory_error = true
        format.html { render :action => 'show' }
      end
    end
  end

  protected

  # Finds the +ContactForm+ object corresponding to the passed in +id+ parameter.
  def find_contact_form
    @contact_form = @node.content
  end

  # Find the +ContactFormField+ objects related to the +ContactForm+.
  def find_contact_form_fields
    @contact_form_fields = @contact_form.contact_form_fields.all(:order => :position)
  end

  # Check the fields entered by the user to only use fields that are actually
  # +ContactFormField+ objects, as we do not want the user to add different input data.
  def get_entered_fields
    @entered_fields = get_used_fields_only(@contact_form_field)
    @entered_fields
  end
  
  def get_used_fields_only(contact_fields)
    used_fields = []
    @contact_form_fields.each do |field|
      if !contact_fields["#{field.id}"].blank?
        if field.field_type == 'multiselect'
          value = contact_fields["#{field.id}"].join(';')
        else
          value = contact_fields["#{field.id}"]
        end
        used_fields << [ field.id, field.label, value ]
      end
    end
    
    used_fields
  end

  # Check whether all obligatory fields are entered.
  # Returns +true+ if this is the case, +false+ otherwise.
  def entered_all_obligatory_fields?(array)
    @contact_form.obligatory_field_ids.each do |field_id|
      if array["#{field_id}"].blank?
        return false
      end
    end
    return true
  end
end
