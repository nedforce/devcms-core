# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +LinksBox+ objects.
class LinksBoxesController < ApplicationController
  before_action :find_links_box, only: :show

  # * GET /links_boxes/:id
  # * GET /links_boxes/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.haml
      format.xml { render xml: @children }
    end
  end

  protected

  # Retrieves the requested +LinksBoxes+ object using the passed in +id+ parameter.
  def find_links_box
    @links_box = @node.content
  end
end
