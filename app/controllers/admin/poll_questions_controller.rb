# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to administering +PollQuestion+ objects.
class Admin::PollQuestionsController < Admin::AdminController

  # The +show+, +new+, +create+, +edit+ and +update+ actions need the parent +Node+ object to link the new +PollQuestion+ content node to.
  prepend_before_filter :find_parent_node,     :only => [ :new, :create ]

  # Find the parent +Poll+ object.
  before_filter :find_poll,                    :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +PollQuestion+ object to act upon.
  before_filter :find_poll_question,           :only => [ :show, :edit, :update ]

  # Parse the publication start date for the +create+ and +update+ actions.
  before_filter :parse_publication_start_date, :only => [ :create, :update ]

  before_filter :set_commit_type,              :only => [ :create, :update ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor']

  # Shows the question and a voting form if the requested question is active
  # shows the question's results otherwise.
  #
  # GET /admin/poll_questions/:id
  # GET /admin/poll_questions/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @poll_question.to_xml(:include => :poll_options) }
    end    
  end  

  # * GET /admin/poll_questions/new
  def new
    @poll_question = @poll.poll_questions.build(params[:poll_question])

    2.times { @poll_question.poll_options.build } if @poll_question.poll_options.empty?
  end

  # * GET /admin/poll_questions/:id/edit
  def edit
    @poll_question.attributes = params[:poll_question]
  end

  # * POST /admin/poll_questions
  # * POST /admin/poll_questions.xml
  def create
    params[:poll_question][:active] = !params[:poll_question][:active].blank?
    @poll_question                  = @poll.poll_questions.build(params[:poll_question])
    @poll_question.parent           = @parent_node

    respond_to do |format|
     if @commit_type == 'preview' && @poll_question.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @poll_question }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @poll_question, :status => :created, :location => @poll_question }
      elsif @commit_type == 'save' && @poll_question.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @poll_question, :status => :created, :location => @poll_question }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @poll_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/poll_questions/:id
  # * PUT /admin/poll_questions/:id.xml
  def update
    params[:poll_question][:active] = !params[:poll_question][:active].blank?
    params[:poll_question][:existing_poll_option_attributes] ||= {}

    @poll_question.attributes = params[:poll_question]

    respond_to do |format|
      if @commit_type == 'preview' && @poll_question.valid?
        format.html { render :template => 'admin/shared/update_preview', :locals => { :record => @poll_question }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @poll_question, :status => :created, :location => @poll_question }
      elsif @commit_type == 'save' && @poll_question.save(:user => current_user)
        format.html do
          @refresh = true
          render :template => 'admin/shared/update'
        end
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @poll_question.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Poll+ object that will become this questions parent
  def find_poll
    @poll = @parent_node.content
  end

  # Finds the +PollQuestion+ object corresponding to the passed in +id+ parameter.
  def find_poll_question
    @poll_question = ((@poll) ? @poll.poll_questions : PollQuestion).find(params[:id], :include => :poll_options).current_version
  end
end
