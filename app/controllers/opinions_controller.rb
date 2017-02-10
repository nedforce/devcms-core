# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Poll+ objects.
class OpinionsController < ApplicationController
    
  protected
  
  # GET /poll_questions/:id/results
  # GET /poll_questions/:id/results.xml
  # GET /poll_questions/:id/results.js
  def results # TODO
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'results_side_box', :locals => { :question => @poll_question }
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

end
