# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Comment+ objects.
class CommentsController < ApplicationController
  prepend_before_filter :find_commentable_node, :only => :create

  before_filter :find_comment, :only => :destroy

  # Only admins and final editors are allowed to delete comments
  require_role ['admin', 'final_editor'], :only => :destroy

  # * POST /nodes/1/comments
  # * POST /nodes/1/comments.xml
  def create
    if @node.commentable?
      @comment = @node.comments.build(params[:comment])

      @comment.user = current_user if logged_in?

      respond_to do |format|
        if @comment.save
          format.html { redirect_to @node.content }
          format.js do
            render :update do |page|
              page.replace_html('comment_container', :partial => '/shared/comments', :locals => { :commentable => @node, :comment => @comment })

              page['comment' + @comment.id.to_s].visual_effect :highlight, :startcolor => '#D9EAF2'
            end
          end
          format.xml { render :xml => @comment, :status => :created, :location => @comment }
        else
          format.html { render :action => :new }
          format.js do
            render :update do |page|
              page.replace_html('new_comment_container', :partial => '/shared/new_comment', :locals => { :commentable => @node, :comment => @comment })
            end
          end
          format.xml { render :xml => @comment.errors, :status => :unprocessable_entity }
        end
      end
    else
      redirect_back_or_default
    end
  end

  # * DELETE /nodes/1/comments/1
  # * DELETE /nodes/1/comments/1.xml
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to @node.content }
      format.xml  { head :ok }
    end
  end

protected

  def find_commentable_node
    @node = current_site.self_and_descendants.accessible.include_content.find(params[:node_id])
  end

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
