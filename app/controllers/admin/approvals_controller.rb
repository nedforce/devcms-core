# This controller is used to approve content created or changed by editors.
# Only final_editors and admins can approve content

class Admin::ApprovalsController < Admin::AdminController
  
  # Require users to have at least one of the roles +admin+ or +final_editor+.
  require_role [ 'admin', 'final_editor' ], :any_node => true

  before_filter :find_node, :only => [ :approve, :reject ]
  before_filter :set_paging
  
  skip_before_filter :find_node  
  skip_before_filter :set_actions
  
  # * GET /approvals
  # * GET /approvals.xml
  def index
    @active_page = :approvals

    respond_to do |format|
      format.html
      format.xml do
        @approvals       = Node.unapproved.select{|node| current_user.has_role_on?(['admin','final_editor'], node)}
        @approvals       = @approvals[@page_limit*(@current_page-1), @page_limit].to_a
        @approvals_count = Node.unapproved.count
        render :action => :index, :layout => false
      end
    end    
  end
  
  # This method is used to approve an unapproved +node+
  # * XHR PUT /admin/approvals/approve/2.xml
  def approve
    @node = Node.find(params[:id])
    respond_to do |format|
      if @node.approvable?
        if @node.content.save_for_user(current_user)
          UserMailer.deliver_approval_notification(@current_user, @node, params[:comment], :host => request.host)
          format.xml { head :ok }
        else
          format.xml { head :internal_server_error }
        end
      else 
        format.xml { head :unprocessable_entity }
      end
    end
  end
    
  # This method is used to reject an unapproved +node+
  # * XHR PUT /admin/approvals/reject/2.xml
  def reject
    @node = Node.find(params[:id])
    respond_to do |format|
      if @node.approvable?
        if !@node.approved?
          if @node.reject! === true
            UserMailer.deliver_rejection_notification(@current_user, @node, params[:reason], :host => request.host)
            format.xml { head :ok }
          else
            format.xml { head :internal_server_error }
          end
        end
      else 
        format.xml { head :unprocessable_entity }
      end
    end
  end
  
  # This method does not actually implement a create action. It serves to
  # satisfy the ExtJS PagingToolbar, which sends its current page using the
  # POST method. This is delegated to the index method.
  def create
    index
  end
end
