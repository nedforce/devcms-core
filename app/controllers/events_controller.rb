# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Event+ objects.
class EventsController < ApplicationController

  # The +show+ action needs a +CalendarItem+ object to work with.
  before_filter :find_calender_item, :only => :show

  # * GET /calender_items/:id
  # * GET /calender_items/:id.xml
  def show
    respond_to do |format|
      format.html { find_images_and_attachments }
      format.xml  { render :xml => @calendar_item }
    end
  end

  protected

  # Finds the +CalendarItem+ object corresponding to the passed in +id+ parameter.
  def find_calender_item
    @calendar_item = @node.content
  end
end
