class Admin::ResponseFieldsController < Admin::AdminController 
  
  before_filter :find_contact_form, :find_response, :find_response_field
  
  layout false
  
  def file
    if @response_field.file?
      send_file(@response_field.file.path)
    else
      render :nothing => true, :status => :not_found
    end
  end
  
private

  def find_contact_form
    @contact_form = ContactForm.find(params[:contact_form_id])
  end

  def find_response
    @response = @contact_form.responses.find(params[:response_id])
  end

  def find_response_field
    @response_field = @response.response_fields.find(params[:id])
  end

end
