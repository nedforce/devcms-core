# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Section+ objects.
class SectionsController < ApplicationController

  before_filter :find_section,                :only => :show
  before_filter :find_images_and_attachments, :only => :show
  before_filter :find_children,               :only => :show

  # * GET /sections/:id
  # * GET /sections/:id.xml
  def show
    respond_to do |format|
      format.html #show.html.erb
      format.xml { render :xml => @children }
    end
  end

protected

  # Retrieves the requested +Section+ object using the passed in +id+ parameter.
  def find_section
    @section = @node.content
  end

  def find_children
    @children = @node.accessible_content_children(:for => current_user, :exclude_content_type => %w( Image Attachment SearchPage) )
  end

end
