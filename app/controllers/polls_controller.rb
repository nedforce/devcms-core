# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Poll+ objects.
class PollsController < ApplicationController
  
  before_filter :find_poll, :only => :show

  before_filter :find_poll_questions, :only => :show
  
  # Shows the currently active question if one is active, and an overview
  # of previously run poll questions.
  # 
  # GET /polls/1
  # GET /polls/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @poll.to_xml(:include => :poll_questions) }
    end
  end
  
protected
  
  def find_poll
    @poll = Poll.find_accessible(params[:id], :for => current_user)
  end

  def find_poll_questions
    @question          = @poll.active_question
    @earlier_questions = @poll.poll_questions.find_accessible(:all, :order => 'poll_questions.created_at DESC', :for => current_user) - [@question]
  end

end
