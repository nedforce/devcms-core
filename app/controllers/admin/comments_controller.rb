# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +Comment+ and +ForumPost+ objects.
class Admin::CommentsController < Admin::AdminController
  before_filter :set_show_forum_posts
  before_filter :set_comment_class
  before_filter :set_paging,  :only => :index
  before_filter :set_sorting, :only => :index

  skip_before_filter :set_actions
  skip_before_filter :find_node    

  require_role [ 'admin', 'final_editor', 'editor'], :any_node => true, :except => :new

  layout false

  # * GET /admin/comments
  # * GET /admin/comments.json
  def index
    @active_page = :comments

    @comments   = @comment_class.editable_comments_for(current_user, :order => "#{@sort_field} #{@sort_direction}")
    start_index = (@page_limit * (@current_page - 1))

    respond_to do |format|
      format.html { render :layout => 'admin' }
      format.json do
        comments = (@comments[start_index, @page_limit] || []).collect do |comment|
          {
            :id         => comment.id,
            :user_name  => comment.user_name,
            :subject    => @show_forum_posts ? I18n.t('comments.no_subject') : (comment.commentable.present? ? comment.commentable.content.title : ''),
            :comment    => comment.comment,
            :updated_at => comment.updated_at
          }
        end
        render :json => { :comments => comments, :total_count => @comments.size }.to_json, :status => :ok
      end
    end
  end

  # * PUT /admin/comments/:id.json
  def update
    @comment = @comment_class.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.json { head :ok }
      else
        format.json { render :json => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Destroys a +Comment+.
  # * DELETE /admin/comments/:id.json
  def destroy
   @comment = @comment_class.find(params[:id])

   respond_to do |format|
      if @comment.destroy
        format.json { head :ok }
      else
        format.json { render :json => @comment.errors.full_messages.join(' '), :status => :unprocessable_entity }
      end
   end
  end

protected

  # Finds sorting parameters.
  def set_sorting
    if extjs_sorting?
      @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')

      params[:sort] = 'body' if @show_forum_posts && params[:sort] == 'comment'
      if @comment_class.columns.map(&:name).include?(params[:sort])
        @sort_field = ActiveRecord::Base.connection.quote_column_name(params[:sort])
      else
        @sort_field = 'updated_at'
      end
    else
      @sort_field = 'updated_at'
    end

    if @sort_field =~ /updated_at/
      @sort_field = "#{@sort_field}"        unless @sort_field =~ /id/
    else
      @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id/
    end
  end

  def set_show_forum_posts
    @show_forum_posts = params[:comment_type] == 'forum_post'
  end

  def set_comment_class
    @comment_class = @show_forum_posts ? ForumPost : Comment
  end
end
