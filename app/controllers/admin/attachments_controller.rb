class Admin::AttachmentsController < Admin::AdminController 

  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  before_filter :find_attachment,        :except => [ :new, :create, :ajax ]

  before_filter :login_required

  require_role [ 'admin', 'final_editor', 'editor' ]

  layout false

  # * GET /admin/attachments/:id
  # * GET /admin/attachments/:id.xml
  def show    
    respond_to do |format|
      format.html { render :partial => 'show', :locals => { :record =>  @attachment }, :layout => 'admin/admin_show' }
      format.xml  { render :xml => @attachment }
    end   
  end

  # * GET /admin/attachments/:id/previous
  # * GET /admin/attachments/:id/previous.xml
  def previous
    @attachment = @attachment.previous_version
    show
  end

  # * GET /admin/attachments/:id/preview.jpg
  def preview
    if params.has_key?(:basename)
      # only upload this to the user if it is what he expects
      upload_file
    else
      if @attachment.extension
        redirect_to url_for(:id => @attachment.id, :action => :preview, :basename => @attachment.basename, :baseformat => @attachment.extension)
      else
        redirect_to url_for(:id => @attachment.id, :action => :preview, :basename => @attachment.basename)
      end
    end
  end
  
  # * GET /admin/attachments/new
  def new
    @attachment = Attachment.new
  end
  
  # * GET /admin/attachments/:id/edit
  def edit
  end

  # * POST /admin/attachments
  # * POST /admin/attachments.js
  # * POST /admin/attachments.xml
  def create
    params[:attachment].delete(:filename) if params[:attachment][:filename].blank? # find out from the uploaded file
    @attachment        = Attachment.new(params[:attachment])
    @attachment.parent = @parent_node

    respond_to do |format|
      if @attachment.save(:user => current_user)  

        format.html # create.html.erb
        format.xml  { render :xml => @attachment, :status => :created, :location => @attachment }
        format.js do
          responds_to_parent do |page|
            page << "if(Ext.get('no_attachments_row')) Ext.get('no_attachments_row').remove();"
            page.insert_html(:bottom, "uploaded_attachments", "<tr id=\"uploaded_attachment_#{@attachment.id}\"><td>#{h(@attachment.title)}</td><td>#{h(@attachment.filename)}</td><td>#{(@attachment.size||0)/1024} KB</td></tr>")
            page.call("treePanel.refreshNodesOf", @parent_node.id)
            @attachment = Attachment.new # To reset fields
            page.replace_html("right_panel_form", :partial => 'form')
          end
        end
      else
        format.html { render :action => :new, :status => :unprocessable_entity }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
        format.js do
          responds_to_parent do |page|
            # rerender form with error messages:
            page.replace_html('right_panel_form', :partial => 'form')
          end
        end
      end
    end
  end
  
  # * PUT /admin/attachments/:id
  # * PUT /admin/attachments/:id.xml
  def update
    @attachment.attributes = params[:attachment]
    
    respond_to do |format|      
      if @attachment.save(:user => current_user, :approval_required => @for_approval)
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit, :status => :unprocessable_entity }
        format.xml  { render :xml => @attachment.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

    def find_attachment
      @attachment = Attachment.find(params[:id]).current_version
    end

    def upload_file
      if @attachment.filename == "#{params[:basename]}.#{params[:baseformat]}" || @attachment.filename == params[:basename]
        send_file(@attachment.file.path, 
                  :type        => @attachment.content_type, 
                  :filename    => @attachment.filename, 
                  :length      => @attachment.size, 
                  :disposition => 'attachment',
                  :stream      => true )
      else
        respond_to do |format|
          format.html { render :nothing => true, :status => :not_found }
        end
      end
    end
end
