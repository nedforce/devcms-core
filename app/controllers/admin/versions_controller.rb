# This controller is used to approve or reject content created or changed by editors.
# Only final_editors and admins can approve content

class Admin::VersionsController < Admin::AdminController
  
  # Require users to have at least one of the roles +admin+ or +final_editor+.
  require_role [ 'admin', 'final_editor' ], :any_node => true

  before_filter :find_versions, :only => [ :index, :approve, :reject ]
  before_filter :find_version, :only => [ :approve, :reject ]
  before_filter :set_paging
  
  skip_before_filter :find_node  
  skip_before_filter :set_actions
  
  # * GET /versions
  # * GET /versions.xml
  def index
    @active_page = :versions

    respond_to do |format|
      format.html
      format.xml do
        find_versions
        @versions_count  = @versions.size
        @versions        = @versions[ @page_limit * (@current_page - 1), @page_limit ].to_a
        render :action => :index, :layout => false
      end
    end    
  end
  
  # This method is used to approve an unapproved +node+
  # * XHR PUT /admin/versions/2/approve.xml
  def approve
    respond_to do |format|
      if @version.approve!(current_user)
        UserMailer.deliver_approval_notification(current_user, @version.versionable.node, @version.editor, params[:comment], :host => request.host) if @version.editor
        format.xml { head :ok }
      else
        format.xml { head :internal_server_error }
      end
    end
  end
    
  # This method is used to reject an unapproved +node+
  # * XHR PUT /admin/versions/2/reject.xml
  def reject
    respond_to do |format|
      if @version.reject!
        UserMailer.deliver_rejection_notification(current_user, @version.versionable.node, @version.editor, params[:reason], :host => request.host) if @version.editor
        format.xml { head :ok }
      else
        format.xml { head :internal_server_error }
      end
    end
  end
  
  # This method does not actually implement a create action. It serves to
  # satisfy the ExtJS PagingToolbar, which sends its current page using the
  # POST method. This is delegated to the index method.
  def create
    index
  end
  
  protected
  
    def find_versions
      @versions = Version.unapproved.select { |version| current_user.has_role_on?(['admin','final_editor'], version.versionable.node )}
    end
  
    def find_version
      @version = Version.unapproved.find(params[:id], :conditions => [ 'id in (?)', @versions.map(&:id) ])
    end
end
