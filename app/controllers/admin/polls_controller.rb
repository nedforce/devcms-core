# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to administering +Poll+ objects.
class Admin::PollsController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +Poll+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +Poll+ object to act upon.
  before_filter :find_poll,                :only => [ :show, :edit, :update ]

  before_filter :find_poll_questions,      :only => :show

  before_filter :set_commit_type,          :only => [ :create, :update ]

  layout false

  # Editors can not administer +Poll+ nodes.
  require_role [ 'admin', 'final_editor'], :except => :show

  # * GET /admin/polls/:id
  # * GET /admin/polls/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @poll }
    end
  end  
  
   # * GET /admin/polls/new
  def new
    @poll = Poll.new(params[:poll])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :record => @poll }}
    end
  end

  # * GET /admin/polls/:id/edit
  def edit
    @poll.attributes = params[:poll]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :record => @poll }}
    end
  end

  # * POST /admin/polls
  # * POST /admin/polls.xml
  def create
    @poll        = Poll.new(params[:poll])
    @poll.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @poll.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :record => @poll }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @poll, :status => :created, :location => @poll }
      elsif @commit_type == 'save' && @poll.save(:user => current_user)
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @poll, :status => :created, :location => @poll }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :record => @poll }, :status => :unprocessable_entity }
        format.xml  { render :xml => @poll.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/polls/:id
  # * PUT /admin/polls/:id.xml
  def update
    @poll.attributes = params[:poll]

    respond_to do |format|
      if @commit_type == 'preview' && @poll.valid?
        format.html {
          find_poll_questions
          render :template => 'admin/shared/update_preview', :locals => { :record => @poll }, :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @poll, :status => :created, :location => @poll }
      elsif @commit_type == 'save' && @poll.save(:user => current_user)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :record => @poll }, :status => :unprocessable_entity }
        format.xml  { render :xml => @poll.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +Poll+ object corresponding to the passed in +id+ parameter.
  def find_poll
    @poll = Poll.find(params[:id], :include => :node).current_version
  end

  def find_poll_questions
    @question          = @poll.active_question
    @earlier_questions = @poll.poll_questions.accessible.all(:order => 'poll_questions.created_at DESC') - [@question]
  end
end
