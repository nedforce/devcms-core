# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to ContentCopy objects.
class Admin::ContentCopiesController < ApplicationController

  before_filter         :find_node,         :only => :show

  # Only the +create+ action needs a parent Node object.
  prepend_before_filter :find_parent_node,  :only => :create

  # The +show+ action needs a ContentCopy object to act upon.
  before_filter         :find_content_copy, :only => [ :show, :previous ]

  layout false

  require_role [ 'admin', 'final_editor', 'editor' ]

  # * GET /admin/content_copies/:id
  # * GET /admin/content_copies/:id.xml
  def show
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record => @content_copy }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @content_copy }
    end
  end 

  # * GET /admin/content_copies/:id/previous
  # * GET /admin/content_copies/:id/previous.xml
  def previous
    @content_copy = @content_copy.previous_version
    show
  end

  # * POST /admin/content_copies.json
  # * POST /admin/content_copies.xml
  def create
    @content_copy        = ContentCopy.new(params[:content_copy])    
    @content_copy.parent = @parent_node

    respond_to do |format|
      if @content_copy.save_for_user(current_user) 
        @content_copy.node.move_to_right_of(@content_copy.copied_node)
        format.json { render :json => { :notice => I18n.t('nodes.content_copy_creation_successful'), :status => :ok } }
        format.xml  { head :ok }
      else
        format.json { render :json => { :errors => @content_copy.errors.full_messages }.to_json, :status => :precondition_failed }
        format.xml  { head :precondition_failed }
      end
    end
  end

protected

  # Finds the ContentCopy object corresponding to the passed in +id+ parameter.
  def find_content_copy
    @content_copy = ContentCopy.find(params[:id], :include => [ :copied_node ])
  end
end
