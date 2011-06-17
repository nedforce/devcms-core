# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Sites+ objects.
class SitesController < ApplicationController

  before_filter :find_site,                   :only => :show
  before_filter :find_images_and_attachments, :only => :show
  before_filter :find_children,               :only => :show

  # * GET /sites/:id
  # * GET /sites/:id.xml
  def show
    respond_to do |format|
      format.html do
        @section = @site
        render :template => "sections/show"
      end
      format.xml { render :xml => @children }
    end
  end

protected

  # Retrieves the requested +Site+ object using the passed in +id+ parameter.
  def find_site
    @site = @node.approved_content
  end

  def find_children
    @children = @node.accessible_content_children(:for => current_user, :exclude_content_type => %w( Image Attachment SearchPage) )
  end

end
