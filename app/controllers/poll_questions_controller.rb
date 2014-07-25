# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +PollQuestion+ objects.
class PollQuestionsController < ApplicationController
  
  include PollQuestionsHelper
  
  before_filter :find_poll_question
  
  # Shows the question and a voting form if the requested question is active
  # shows the question's results otherwise.
  #
  # GET /poll_questions/:id
  # GET /poll_questions/:id.xml
  def show
    unless @poll_question.active?
      render :action => 'results'
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml { render :xml => @poll_question.to_xml(:include => :poll_options) }
      end
    end
  end

  # GET /poll_questions/:id/results
  # GET /poll_questions/:id/results.xml
  # GET /poll_questions/:id/results.js
  def results
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'results_side_box', :locals => {:question => @poll_question}
        else
          render
        end
      end
      format.xml do
        render :xml => @poll_question.to_xml do |xml|
          xml.poll_options do
            @poll_question.poll_options.each do |o|
              xml.poll_option do
                xml.text o.id, "type" => "integer"
                xml.text o.text
                xml.votes o.poll_votes.count, "type" => "integer"
              end
            end
          end
        end # of render
      end # of xml
    end # of respond_to
  end

  # PUT /poll_questions/:id/vote
  # PUT /poll_questions/:id/vote.xml
  # PUT /poll_questions/:id/vote.js
  #
  # *parameters*
  # 
  # +poll_option_id+ - The id of this question's option to cast a vote for. (Required)
  def vote
    already_voted = already_voted_for?(@poll_question)

    if @poll_question.active? && !already_voted
      @poll_question.vote(params[:poll_option_id], current_user)
      @poll_question.reload
      bake_vote_cookie_for(@poll_question) unless @poll_question.poll.requires_login?
    end

    respond_to do |format|
      format.html do
        if already_voted
          flash[:warning] = I18n.t('polls.already_voted')
        elsif !poll_enabled?(@poll_question.poll)
          flash[:warning] = I18n.t('polls.requires_login')
        elsif !@poll_question.active?
          flash[:warning] = I18n.t('polls.question_not_active')
        else # redirect to results page
          flash[:notice]  = I18n.t('polls.you_voted')
        end
        redirect_to results_poll_question_url(@poll_question)        
      end
      format.js do
        render :update do |page|
          page.alert I18n.t('polls.already_voted')       if already_voted
          page.alert I18n.t('polls.question_not_active') if !@poll_question.active?
          page.alert I18n.t('polls.requires_login')      unless poll_enabled?(@poll_question.poll)
          page.replace_html "poll_content_box_content_#{@poll_question.poll.id}", :partial => 'results_side_box', :locals => { :question => @poll_question }
        end
      end
    end
  end

  protected

  def find_poll_question
    @poll_question = @node.content
  end
end
