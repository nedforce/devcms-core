# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +InternalLink+ and +ExternalLink+ objects.
class LinksController < ApplicationController

  before_filter :find_link, :only => :show

  # The +show+ action for a given +InternalLink+ or +ExternalLink+ object
  # performs a redirect to the represented link. In the case of an
  # +InternalLink+ object, an internal redirect is issued. In the case of an
  # +ExternalLink+ object, an external redirect is issued.
  #
  # * GET /sections/:id
  # * GET /sections/:id.xml
  def show
    respond_to do |format|
      format.html { redirect_to generate_url_for_link(@link) }
      format.xml  { head :ok }
    end
  end

  protected

  # Retrieves the requested +Link+ object using the passed in +id+ parameter.
  def find_link
    @link = @node.content
  end

  # Generates the URL for the given +Link+ object.
  def generate_url_for_link(link)
    if link.is_a? InternalLink
      aliased_or_delegated_path link.linked_node
    else # ExternalLink
      link.url
    end
  end
end
