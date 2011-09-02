# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +SocialMediaLinksBox+ objects.
class SocialMediaLinksBoxesController < ApplicationController

  before_filter :find_social_media_links_box, :only => :show

  # * GET /social_media_links_boxes/:id
  # * GET /social_media_links_boxes/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @social_media_links_box }
    end
  end

  protected

  # Finds the +SocialMediaLinksBox+ object corresponding to the passed in +id+ parameter.
  def find_social_media_links_box
    @social_media_links_box = @node.content
  end
end
