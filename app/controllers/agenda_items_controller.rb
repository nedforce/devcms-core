# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +AgendaItem+ objects.

class AgendaItemsController < ApplicationController
  
  # The +show+ action needs a +AgendaItem+ object to work with.
  # Also any possible +Attachment+ objects need to be retrieved for the +show+ action.
  before_filter :find_agenda_item, :find_images_and_attachments, :only => :show
    
  # * GET /agenda_items/:id
  # * GET /agenda_items/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agenda_item }
    end
  end
  
protected

  # Finds the +AgendaItem+ object corresponding to the passed in +id+ parameter.
  def find_agenda_item
    @agenda_item = @node.approved_content
  end

end
