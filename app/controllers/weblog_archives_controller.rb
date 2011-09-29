# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +WeblogArchive+ objects.
class WeblogArchivesController < ApplicationController
  
  # The +show+ action needs a +WeblogArchive+ object to work with.  
  before_filter :find_weblog_archive, :only => :show
  before_filter :find_weblogs, :only => :show
   
  # * GET /weblog_archives/1
  # * GET /weblog_archives/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @weblog_archive }
    end
  end
 
protected
  
  # Finds the +WeblogArchive+ object corresponding to the passed in +id+ parameter.
  def find_weblog_archive
    @weblog_archive = @node.content
  end

  def find_weblogs
    @weblogs = @weblog_archive.weblogs.find_accessible(:all, :for => current_user, :page => {:current => params[:page]})
  end
  
end
