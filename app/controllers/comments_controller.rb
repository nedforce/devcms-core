# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +Comment+ objects.
class CommentsController < ApplicationController

  before_filter :find_node,    :only => :create
  before_filter :find_comment, :only => :destroy

  # Only admins and final editors are allowed to delete comments
  require_role [ 'admin', 'final_editor' ], :only => :destroy

  # * POST /nodes/:id/comments
  # * POST /nodes/:id/comments.xml
  def create
    if @node.commentable?
      @comment = @node.comments.build(params[:comment])
      # TODO: Current user weer toevoegen
      @comment.user = current_user if logged_in?
      respond_to do |format|
        if @comment.save
          format.html { redirect_to @node.content }
          format.js   { 
            render :update do |page|
              page.replace_html('comment_container', :partial => '/shared/comments', :locals => { :commentable => @node, :comment => @comment })

              page['comment' + @comment.id.to_s].visual_effect :highlight, :startcolor => "#D9EAF2"
            end
          }
          format.xml  { render :xml => @comment, :status => :created, :location => @comment }
        else
          format.html { render :action => :new }
          format.js   { 
            render :update do |page|
              page.replace_html('new_comment_container', :partial => '/shared/new_comment', :locals => { :commentable => @node, :comment => @comment })
            end
          }
          format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_back_or_default
    end
  end

  # * DELETE /nodes/:id/comments
  # * DELETE /nodes/:id/comments.xml
  def destroy    
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @node.content }
      format.xml  { head :ok }
    end
  end

protected

  def find_comment 
    @comment = @node.comments.find(params[:id])
  end

  # Renders the general deletion confirmation form, and cancels the chain.
  # Overrides the default +confirm_destroy+ as defined in ApplicationController to
  # firstly find the comment.
  def confirm_destroy
    find_comment
    super
  end
end
