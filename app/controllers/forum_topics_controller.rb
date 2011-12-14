# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +ForumTopic+ objects.
class ForumTopicsController < ApplicationController
  
  # The +show+ action needs a +ForumTopic+ object to work with.  
  before_filter :find_forum_topic,   :only => :show
  before_filter :find_forum_threads, :only => :show

  # * GET /forum_topics/:id
  # * GET /forum_topics/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @forum_topic }
    end
  end

protected

  # Finds the +ForumTopic+ object corresponding to the passed in +id+ parameter.
  def find_forum_topic
    @forum_topic = @node.content
  end

  def find_forum_threads
    @forum_threads = @forum_topic.forum_threads_by_last_update_date(:page => { :size => 25, :current => params[:page] })
  end
  
end
