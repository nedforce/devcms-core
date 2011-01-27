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
        ContactFormMailer.deliver_message(@contact_form, @entered_fields)
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
    @contact_form = @node.approved_content
  end

  # Find the +ContactFormField+ objects related to the +ContactForm+.
  def find_contact_form_fields
    @contact_form_fields = @contact_form.contact_form_fields.find(:all, :order => :position)
  end

  # Check the fields entered by the user to only use fields that are actually
  # +ContactFormField+ objects, as we do not want the user to add different input data.
  def get_entered_fields
    @entered_fields = []
    @contact_form_fields.each do |field|
      if !@contact_form_field["#{field.id}"].blank?
        @entered_fields << [ field.id, field.label, @contact_form_field["#{field.id}"] ]
      end
    end
    @entered_fields
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
