# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsletterEdition+ objects.
class NewsletterEditionsController < ApplicationController
  
  # The +show+ action needs a +NewsletterEditione+ object to work with.  
  before_filter :find_newsletter_edition, :only => :show
   
  # * GET /newsletter_editions/:id
  # * GET /newsletter_editions/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @newsletter_edition }
    end
  end
 
protected
  
  # Finds the +NewsletterEdition+ object corresponding to the passed in +id+ parameter.
  # Will only retrieve editions that have been published or are currently publishing.
  def find_newsletter_edition
    @newsletter_edition = @node.content
    
    raise ActiveRecord::RecordNotFound if @newsletter_edition.published == 'unpublished'
  end
  
end
