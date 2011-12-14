# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Forum+ objects.
class ForumsController < ApplicationController
  
  # The +show+ action needs a +Forum+ object to work with.  
  before_filter :find_forum,        :only => :show
  before_filter :find_forum_topics, :only => :show

  # * GET /forums/:id
  # * GET /forums/:id.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @forum }
    end
  end

protected
  
  # Finds the +Forum+ object corresponding to the passed in +id+ parameter.
  def find_forum
    @forum = @node.content
  end

  def find_forum_topics
    @forum_topics = @forum.forum_topics.all
  end
  
end
