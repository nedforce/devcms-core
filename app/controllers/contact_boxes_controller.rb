# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to ContactBox objects.
class ContactBoxesController < ApplicationController
  before_filter :find_contact_box, :only => :show

  # * GET /contact_boxes/:id
  # * GET /contact_boxes/:id.xml
  def show
    respond_to do |format|
      format.html { redirect_to '/contact' }
      format.xml  { render :xml => @contact_box }
    end
  end

protected

  # Finds the ContactBox object corresponding to the passed in +id+ parameter.
  def find_contact_box
    @contact_box = @node.approved_content
  end
end