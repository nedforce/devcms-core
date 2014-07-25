# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +EventRegistration+ objects.
class EventRegistrationsController < ApplicationController

  before_filter :find_event

  # * POST /events/1/event_registrations
  def create
    @event_registration = @event.event_registrations.build(params[:event_registration])
    @event_registration.user = current_user
    
    respond_to do |format|
      if @event_registration.save
        format.js {
          render :update do |page|
            page.replace_html('registration_container', :partial => '/event_registrations/show', :locals => { :event => @event })
          end
        }
      else
        format.js {
          render :update do |page|
            page.replace_html('event_registration_form', :partial => '/event_registrations/form', :locals => { :event => @event, :event_registration => @event_registration })
          end
        }
      end
    end
  end

  # * DELETE /event_registrations/1
  def destroy
    @event_registration = EventRegistration.find params[:id]
    
    respond_to do |format|
      if @event_registration.user == current_user && @event_registration.destroy
        format.js {
          render :update do |page|
            page.replace_html('registration_container', :partial => '/event_registrations/show', :locals => { :event => @event })
          end
        }
      else
        render :status => :unprocessable_entity
      end
    end
  end
  
  def find_event
    @event = Event.find params[:event_id]
  end

end
