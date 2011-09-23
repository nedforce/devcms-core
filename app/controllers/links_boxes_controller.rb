# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +LinksBox+ objects.
class LinksBoxesController < ApplicationController

  before_filter :find_links_box, :only => :show
  before_filter :find_children,  :only => :show

  # * GET /links_boxes/:id
  # * GET /links_boxes/:id.xml
  def show
    respond_to do |format|
      format.html #show.html.erb
      format.xml { render :xml => @children }
    end
  end

protected

  # Retrieves the requested +LinksBoxes+ object using the passed in +id+ parameter.
  def find_links_box
    @links_box = @node.approved_content
  end

  def find_children
    @children = @node.accessible_content_children(:for => current_user, :exclude_content_type => %w( Image ) )
  end

end
